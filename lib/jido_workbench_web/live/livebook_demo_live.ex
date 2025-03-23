defmodule JidoWorkbenchWeb.LivebookDemoLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.LivebookRegistry
  alias JidoWorkbenchWeb.MenuItems
  require Logger

  @livebook_root "lib/jido_workbench_web/live"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Loading...", livebooks: [], selected_category: nil)}
  end

  @impl true
  def handle_params(params, uri, socket) do
    tag = get_route_tag(uri)
    Logger.debug("Route tag determined as: #{tag} from uri: #{uri}")
    title = if tag == :examples, do: "Examples", else: "Documentation"

    # Get all livebooks for this type (examples or docs)
    livebooks = MenuItems.build_livebook_menu(tag)
    Logger.debug("Built menu for #{tag} with #{length(Enum.drop(livebooks, 1))} categories")

    case params do
      %{"demo_id" => demo_id} ->
        Logger.debug("Looking for livebook with demo_id: #{demo_id} in #{tag}")
        # Find the specific livebook
        selected_livebook = MenuItems.find_livebook(tag, demo_id)

        case selected_livebook do
          nil ->
            Logger.warning("Livebook not found for demo_id: #{demo_id} in #{tag}")

            {:noreply,
             socket
             |> put_flash(:error, "Livebook not found")
             |> push_navigate(to: ~p"/#{tag}")}

          livebook ->
            Logger.debug("Found livebook: #{livebook.label}")
            # Construct the actual filesystem path
            file_path =
              Path.join([
                @livebook_root,
                to_string(tag),
                demo_id |> String.split("-") |> Path.join()
              ])

            Logger.debug("Attempting to load content from base path: #{file_path}")
            livebook_content = LivebookRegistry.get_livebook_content(file_path)

            case livebook_content do
              nil ->
                Logger.warning("Failed to load content for livebook: #{file_path}")

                {:noreply,
                 socket
                 |> put_flash(:error, "Failed to load livebook content")
                 |> push_navigate(to: ~p"/#{tag}")}

              content ->
                # Process the content for table of contents
                {html_content, toc} = process_livebook_content(content.content)

                {:noreply,
                 assign(socket,
                   page_title: livebook.label,
                   livebooks: livebooks,
                   selected_livebook: livebook,
                   livebook_content: %{html: html_content, toc: toc},
                   livebook_path: file_path,
                   tag: tag
                 )}
            end
        end

      _ ->
        # Index view - show all livebooks and index content if available
        has_index = LivebookRegistry.has_index?(tag)
        index_content = if has_index, do: LivebookRegistry.get_index_content(tag), else: nil

        {html_content, toc} =
          if index_content do
            process_livebook_content(index_content.content)
          else
            {nil, nil}
          end

        {:noreply,
         assign(socket,
           page_title: title,
           livebooks: livebooks,
           selected_livebook: nil,
           index_content: %{html: html_content, toc: toc},
           tag: tag
         )}
    end
  end

  @impl true
  def handle_event("refresh_livebooks", _, socket) do
    type = socket.assigns.tag || :docs
    :ok = JidoWorkbench.LivebookRegistry.refresh_cache(type)
    Process.delete(:"livebook_menu_#{type}")
    livebooks = JidoWorkbenchWeb.MenuItems.build_livebook_menu(type)

    {:noreply,
     socket
     |> assign(:livebooks, livebooks)
     |> put_flash(:info, "Successfully refreshed #{type} library")
    }
  end

  defp get_route_tag(uri) do
    # Extract the first part of the path to determine if we're in docs or examples
    path = URI.parse(uri).path || "/"
    base_path = path |> String.split("/") |> Enum.at(1, "")

    case base_path do
      "docs" -> :docs
      "examples" -> :examples
      # Default to examples for root path
      _ -> :examples
    end
  end

  defp process_livebook_content(content) do
    # Configure Earmark to add language classes to code blocks
    options = %Earmark.Options{
      code_class_prefix: "language-",
      gfm: true,
      breaks: true
    }

    # First pass: Extract headers and build TOC
    {:ok, ast, _} = Earmark.Parser.as_ast(content)
    toc = build_table_of_contents(ast)

    # Second pass: Generate HTML content
    case Earmark.as_html(content, options) do
      {:ok, html_doc, _} ->
        # Add IDs to headers for scrolling
        html_doc = add_header_ids(html_doc)
        # Add highlight.js initialization
        html_doc = "<div phx-hook=\"Highlight\">#{html_doc}</div>"
        {html_doc, toc}

      {:error, _, error_messages} ->
        Logger.warning("Failed to parse livebook markdown: #{inspect(error_messages)}")
        {"<p>Error processing content</p>", []}
    end
  end

  defp build_table_of_contents(ast) do
    ast
    |> Enum.reduce([], fn
      {"h1", attrs, [title], _}, acc when is_binary(title) ->
        id = get_header_id(attrs) || slugify(title)
        [%{id: id, title: title, level: 1, children: []} | acc]

      {"h2", attrs, [title], _}, acc when is_binary(title) ->
        id = get_header_id(attrs) || slugify(title)
        [%{id: id, title: title, level: 2, children: []} | acc]

      {"h3", attrs, [title], _}, acc when is_binary(title) ->
        id = get_header_id(attrs) || slugify(title)

        case acc do
          [%{level: 2} = parent | rest] ->
            [%{parent | children: [%{id: id, title: title, level: 3} | parent.children]} | rest]

          _ ->
            [%{id: id, title: title, level: 3, children: []} | acc]
        end

      _, acc ->
        acc
    end)
    |> Enum.reverse()
  end

  defp get_header_id(attrs) do
    case Enum.find(attrs || [], fn {key, _} -> key == "id" end) do
      {_, id} -> id
      _ -> nil
    end
  end

  defp slugify(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
    |> String.trim("-")
  end

  # Add IDs to headers for scrolling
  defp add_header_ids(html) do
    Regex.replace(~r/<(h[1-3])>(.*?)<\/\1>/s, html, fn _, tag, content ->
      id = slugify(content)
      "<#{tag} id=\"#{id}\">#{content}</#{tag}>"
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={@tag}>
      <div class="bg-white dark:bg-secondary-900 text-secondary-900 dark:text-secondary-100">
        <div class="max-w-[calc(100%-1rem)] mx-auto px-6 py-6">
          <div class="flex gap-8">
            <%!-- Main Content --%>
            <div class="flex-1 max-w-[calc(100%-20rem)]">
              <%= if @selected_livebook do %>
                <div class="space-y-8">
                  <div class="space-y-4">
                    <div class="flex items-center justify-between">
                      <div class="space-y-1">
                        <.link
                          navigate={~p"/#{@tag}"}
                          class="text-primary-600 dark:text-primary-500 hover:text-primary-700 dark:hover:text-primary-400 mb-2 flex items-center gap-1"
                        >
                          <.icon name="hero-arrow-left" class="w-4 h-4" />
                          <span>
                            Back to {if @tag == :examples, do: "Examples", else: "Documentation"}
                          </span>
                        </.link>
                        <h1 class="text-4xl font-bold text-primary-600 dark:text-primary-500">
                          {@selected_livebook.label}
                        </h1>
                      </div>
                      <div class="text-primary-600 dark:text-primary-500">
                        <.icon name={@selected_livebook.icon} class="w-8 h-8" />
                      </div>
                    </div>
                    <p class="text-lg text-secondary-600 dark:text-secondary-400">
                      {@selected_livebook.description}
                    </p>
                  </div>

                  <%= if @livebook_content do %>
                    <div class="prose dark:prose-invert max-w-none prose-pre:bg-secondary-100 dark:prose-pre:bg-secondary-800 prose-pre:border-0 prose-pre:rounded-lg prose-pre:w-full prose-pre:p-4">
                      {raw(@livebook_content.html)}
                    </div>
                  <% end %>
                </div>
              <% else %>
                <%!-- Index Page --%>
                <div class="max-w-4xl">
                  <%!-- Header Section --%>
                  <div class="mb-6 flex justify-between items-center">
                    <h1 class="text-3xl font-bold text-primary-600 dark:text-primary-500">
                      {if @tag == :examples, do: "Examples", else: "Documentation"}
                    </h1>
                    <!--button phx-click="refresh_livebooks" class="px-3 py-2 bg-primary-600 hover:bg-primary-700 text-white rounded-md flex items-center gap-1">
                      <.icon name="hero-arrow-path" class="w-4 h-4" />
                      <span>Refresh</span>
                    </button-->
                  </div>

                  <%!-- Index Content --%>
                  <%= if @index_content && @index_content.html do %>
                    <div class="prose dark:prose-invert max-w-none mb-8 prose-pre:bg-secondary-100 dark:prose-pre:bg-secondary-800 prose-pre:border-0 prose-pre:rounded-lg prose-pre:w-full prose-pre:p-4">
                      {raw(@index_content.html)}
                    </div>
                  <% end %>

                  <%!-- Categories/Items Grid --%>
                  <h2 class="text-xl font-bold text-primary-600 dark:text-primary-500 mb-4">
                    {if @tag == :examples, do: "Examples", else: "Documentation"}
                  </h2>
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <%= for item <- Enum.drop(@livebooks, 1) do %>
                      <%= if Map.has_key?(item, :menu_items) do %>
                        <%!-- Render Category with multiple items --%>
                        <div class="bg-secondary-100 dark:bg-secondary-800 p-6 rounded-lg">
                          <h3 class="text-xl font-semibold text-primary-600 dark:text-primary-500 mb-4">
                            {item.label}
                          </h3>
                          <div class="space-y-3">
                            <%= for menu_item <- item.menu_items do %>
                              <.link navigate={menu_item.path} class="block">
                                <div class="p-4 rounded-lg hover:bg-secondary-200 dark:hover:bg-secondary-700 transition-colors">
                                  <div class="flex items-center gap-3">
                                    <div class="text-primary-600 dark:text-primary-500">
                                      <.icon name={menu_item.icon} class="w-6 h-6" />
                                    </div>
                                    <div>
                                      <h4 class="text-lg font-medium text-primary-600 dark:text-primary-500">
                                        {menu_item.label}
                                      </h4>
                                      <%= if menu_item[:description] do %>
                                        <p class="text-sm text-secondary-600 dark:text-secondary-400 mt-1">
                                          {menu_item.description}
                                        </p>
                                      <% end %>
                                    </div>
                                  </div>
                                </div>
                              </.link>
                            <% end %>
                          </div>
                        </div>
                      <% else %>
                        <%!-- Render flattened single item --%>
                        <.link navigate={item.path} class="block bg-secondary-100 dark:bg-secondary-800 p-6 rounded-lg hover:bg-secondary-200 dark:hover:bg-secondary-700 transition-colors">
                          <div class="flex items-center gap-3">
                            <div class="text-primary-600 dark:text-primary-500">
                              <.icon name={item.icon} class="w-6 h-6" />
                            </div>
                            <div>
                              <h4 class="text-lg font-medium text-primary-600 dark:text-primary-500">
                                {item.label}
                              </h4>
                              <%= if item[:description] do %>
                                <p class="text-sm text-secondary-600 dark:text-secondary-400 mt-1">
                                  {item.description}
                                </p>
                              <% end %>
                            </div>
                          </div>
                        </.link>
                      <% end %>
                    <% end %>
                  </div>
                </div>
              <% end %>
            </div>

            <%!-- Side Navigation --%>
            <%= if @selected_livebook || (@index_content && @index_content.toc && @index_content.toc != []) do %>
              <div class="hidden lg:block w-64 shrink-0">
                <div id="sidebar" class="sticky top-6 space-y-4" phx-hook="ScrollSpy">
                  <h3 class="text-lg font-semibold text-primary-600 dark:text-primary-500 mb-4">
                    On this Page
                  </h3>
                  <nav class="space-y-1">
                    <%= cond do %>
                      <% @selected_livebook && @livebook_content -> %>
                        <%= for section <- @livebook_content.toc do %>
                          <a
                            href={"##{section.id}"}
                            class="block px-3 py-2 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors text-secondary-700 dark:text-secondary-300 hover:text-primary-600 dark:hover:text-primary-500"
                          >
                            {section.title}
                          </a>
                          <%= if section.children != [] do %>
                            <%= for child <- Enum.reverse(section.children) do %>
                              <a
                                href={"##{child.id}"}
                                class="block pl-6 py-1 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-500 text-sm"
                              >
                                {child.title}
                              </a>
                            <% end %>
                          <% end %>
                        <% end %>

                      <% @index_content && @index_content.toc -> %>
                        <%= for section <- @index_content.toc do %>
                          <a
                            href={"##{section.id}"}
                            class="block px-3 py-2 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors text-secondary-700 dark:text-secondary-300 hover:text-primary-600 dark:hover:text-primary-500"
                          >
                            {section.title}
                          </a>
                          <%= if section.children != [] do %>
                            <%= for child <- Enum.reverse(section.children) do %>
                              <a
                                href={"##{child.id}"}
                                class="block pl-6 py-1 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors text-secondary-600 dark:text-secondary-400 hover:text-primary-600 dark:hover:text-primary-500 text-sm"
                              >
                                {child.title}
                              </a>
                            <% end %>
                          <% end %>
                        <% end %>

                      <% true -> %>
                        <div>No table of contents available</div>
                    <% end %>
                  </nav>

                  <%= if @selected_livebook && @livebook_path do %>
                    <div class="pt-4 border-t border-secondary-200 dark:border-secondary-700">
                      <a
                        href={"https://livebook.dev/run?url=https://github.com/agentjido/jido_workbench/blob/main/#{@livebook_path}"}
                        target="_blank"
                        rel="noopener noreferrer"
                        class="mt-2 w-full flex items-center gap-2 px-3 py-2 text-secondary-700 dark:text-secondary-300 hover:text-primary-600 dark:hover:text-primary-500 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors"
                      >
                        <.icon name="hero-book-open" class="w-4 h-4" />
                        <span>Run in Livebook</span>
                      </a>
                      <a
                        href={"https://github.com/agentjido/jido_workbench/blob/main/#{@livebook_path}"}
                        target="_blank"
                        rel="noopener noreferrer"
                        class="mt-2 w-full flex items-center gap-2 px-3 py-2 text-secondary-700 dark:text-secondary-300 hover:text-primary-600 dark:hover:text-primary-500 hover:bg-secondary-100 dark:hover:bg-secondary-800 rounded-lg transition-colors"
                      >
                        <.icon name="hero-pencil-square" class="w-4 h-4" />
                        <span>Edit in GitHub</span>
                      </a>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </.workbench_layout>
    """
  end
end
