defmodule JidoWorkbenchWeb.DemoShowLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.JidoDemo

  @impl true
  def mount(%{"demo_id" => demo_id}, _session, socket) do
    demos = JidoDemo.list_demos()
    demo = JidoDemo.get_demo_by_id(demos, demo_id)

    case demo do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Demo not found")
         |> push_navigate(to: ~p"/demo/")}

      demo ->
        {prev_demo, next_demo} = get_adjacent_demos(demos, demo)
        livebook_content = load_livebook_content(demo.livebook)

        demo_meta = %{
          version: Map.get(demo, :version, "1.0.0"),
          updated_at: format_updated_at(Map.get(demo, :updated_at)),
          status: Map.get(demo, :status, "Active"),
          sections:
            demo.sections ||
              [
                %{id: "implementation", title: "Implementation"},
                %{id: "demo", title: "Interactive Demo"},
                %{id: "references", title: "Related Resources"}
              ],
          related_resources:
            demo.related_resources ||
              [
                %{
                  title: "Documentation",
                  description: "View full documentation",
                  icon: "hero-link",
                  url: Map.get(demo, :documentation_url, "#")
                },
                %{
                  title: "Source Code",
                  description: "Explore the implementation",
                  icon: "hero-code-bracket",
                  url: Map.get(demo, :source_url, "#")
                }
              ]
        }

        first_file = List.first(Map.get(demo, :source_files, []))
        source_files = load_source_files(Map.get(demo, :source_files, []))

        {:ok,
         assign(socket,
           demo: demo,
           demo_meta: demo_meta,
           page_title: Map.get(demo, :name),
           source_files: source_files,
           selected_file: first_file,
           copied: false,
           prev_demo: prev_demo,
           next_demo: next_demo,
           livebook_html: livebook_content
         )}
    end
  end

  @impl true
  def handle_event("view_source", %{"file" => file}, socket) do
    {:noreply, assign(socket, selected_file: file, copied: false)}
  end

  @impl true
  def handle_event("copy_source", _, socket) do
    {:noreply, assign(socket, copied: true)}
  end

  defp load_source_files(files) do
    files
    |> Enum.reduce(%{}, fn file, acc ->
      case File.read(file) do
        {:ok, content} ->
          Map.put(acc, file, %{
            raw: content,
            # No server-side highlighting
            highlighted: content
          })

        {:error, reason} ->
          IO.warn("Failed to read source file #{file}: #{inspect(reason)}")
          acc
      end
    end)
  end

  defp get_file_extension(file) do
    case Path.extname(file) do
      ".ex" -> "elixir"
      ".exs" -> "elixir"
      ".js" -> "javascript"
      ".ts" -> "typescript"
      # or "elixir" if you prefer
      ".heex" -> "html"
      ext when ext != "" -> String.trim_leading(ext, ".")
      _ -> "plaintext"
    end
  end

  defp format_updated_at(nil), do: "TODO"

  defp format_updated_at(datetime) do
    case DateTime.diff(DateTime.utc_now(), datetime, :day) do
      0 -> "today"
      1 -> "yesterday"
      days when days < 30 -> "#{days} days ago"
      days when days < 365 -> "#{div(days, 30)} months ago"
      days -> "#{div(days, 365)} years ago"
    end
  end

  defp get_adjacent_demos(demos, current_demo) do
    # Find the index of the current demo
    current_index = Enum.find_index(demos, &(&1.id == current_demo.id))

    prev_demo = if current_index > 0, do: Enum.at(demos, current_index - 1)
    next_demo = Enum.at(demos, current_index + 1)

    {prev_demo, next_demo}
  end

  defp load_livebook_content(nil), do: nil

  defp load_livebook_content(path) do
    case File.read(path) do
      {:ok, content} ->
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
            %{html: html_doc, toc: toc}

          {:error, _, error_messages} ->
            IO.warn("Failed to parse livebook markdown: #{inspect(error_messages)}")
            nil
        end

      {:error, reason} ->
        IO.warn("Failed to read livebook file #{path}: #{inspect(reason)}")
        nil
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
end
