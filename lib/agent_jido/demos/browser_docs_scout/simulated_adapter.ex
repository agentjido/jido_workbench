defmodule AgentJido.Demos.BrowserDocsScout.SimulatedAdapter do
  @moduledoc """
  Deterministic `Jido.Browser.Adapter` used by the docs scout example.

  The adapter exposes two fixture documentation pages and a fixed PNG payload so
  the example behaves like a real browser-enabled agent without browser binaries
  or network access.
  """

  @behaviour Jido.Browser.Adapter

  alias Jido.Browser.Error
  alias Jido.Browser.Session

  @overview_url "https://docs.example.dev/jido-browser/plugin-guide"
  @testing_url "https://docs.example.dev/jido-browser/testing-browser-agents"

  @png_base64 "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO7Z0ZkAAAAASUVORK5CYII="
  @png_bytes Base.decode64!(@png_base64)

  @pages %{
    @overview_url => %{
      url: @overview_url,
      title: "Jido Browser Plugin Guide",
      description: "Mount the browser plugin, keep session state deterministic in tests, and swap adapters later.",
      article_markdown: """
      # Jido Browser Plugin Guide

      Use `Jido.Browser.Plugin` when you want browser session configuration to live in your agent state.

      ```elixir
      use Jido.Agent,
        plugins: [{Jido.Browser.Plugin, %{adapter: MyApp.BrowserAdapter, headless: true}}]
      ```

      In a deterministic demo, point the plugin at a simulated adapter.
      In production, swap the adapter to `Jido.Browser.Adapters.Vibium` or `Jido.Browser.Adapters.Web`.
      """,
      links: [
        %{
          selector: "a[data-doc-link='testing']",
          text: "Testing browser agents",
          href: @testing_url
        }
      ]
    },
    @testing_url => %{
      url: @testing_url,
      title: "Testing Browser Agents",
      description: "Run browser-enabled agents locally with a simulated adapter first, then switch to real browser binaries.",
      article_markdown: """
      # Testing Browser Agents

      Start with a simulated adapter so your tests do not need browser binaries or network access.

      When you switch to a real adapter in your own project, add the dependency and install step:

      ```elixir
      {:jido_browser, github: "agentjido/jido_browser", branch: "main"}
      ```

      ```elixir
      defp aliases do
        [
          setup: ["deps.get", "jido_browser.install --if-missing"]
        ]
      end
      ```
      """,
      links: [
        %{
          selector: "a[data-doc-link='overview']",
          text: "Back to plugin guide",
          href: @overview_url
        }
      ]
    }
  }

  @spec overview_url() :: String.t()
  def overview_url, do: @overview_url

  @spec testing_url() :: String.t()
  def testing_url, do: @testing_url

  @spec fixture_pages() :: map()
  def fixture_pages, do: @pages

  @impl true
  def start_session(opts) do
    Session.new!(%{
      adapter: __MODULE__,
      connection: %{
        current_url: nil,
        current_page: nil,
        pages: @pages,
        viewport: Keyword.get(opts, :viewport, %{width: 1280, height: 720})
      },
      opts: Map.new(opts)
    })
  end

  @impl true
  def end_session(_session), do: :ok

  @impl true
  def navigate(%Session{} = session, url, _opts) do
    case Map.fetch(@pages, url) do
      {:ok, page} ->
        updated_session = put_current_page(session, page)

        {:ok, updated_session,
         %{
           url: page.url,
           title: page.title,
           description: page.description,
           link_count: length(page.links)
         }}

      :error ->
        {:error, Error.navigation_error(url, :page_not_found)}
    end
  end

  @impl true
  def click(%Session{} = session, selector, opts) do
    current_page = current_page(session)
    text = Keyword.get(opts, :text)

    with page when is_map(page) <- current_page,
         {:ok, link} <- find_link(page, selector, text),
         {:ok, updated_session, _result} <- navigate(session, link.href, []) do
      {:ok, updated_session,
       %{
         selector: selector,
         href: link.href,
         title: Map.get(updated_session.connection.current_page, :title)
       }}
    else
      nil ->
        {:error, Error.invalid_error("Open a page before clicking a link.")}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def type(%Session{} = session, selector, text, _opts) do
    {:ok, session, %{selector: selector, text: text}}
  end

  @impl true
  def screenshot(%Session{} = session, _opts) do
    case current_page(session) do
      nil ->
        {:error, Error.invalid_error("Open a page before taking a screenshot.")}

      page ->
        {:ok, session, %{bytes: @png_bytes, mime: "image/png", title: page.title}}
    end
  end

  @impl true
  def extract_content(%Session{} = session, opts) do
    case current_page(session) do
      nil ->
        {:error, Error.invalid_error("Open a page before extracting content.")}

      page ->
        selector = Keyword.get(opts, :selector, "body")
        format = Keyword.get(opts, :format, :markdown)

        if format in [:markdown, :html] and selector in ["article", "main", "body"] do
          {:ok, session, %{content: page.article_markdown, format: format}}
        else
          {:error, Error.invalid_error("Unsupported selector or format", %{selector: selector, format: format})}
        end
    end
  end

  @impl true
  def evaluate(%Session{} = session, script, _opts) do
    case {current_page(session), String.trim(script)} do
      {nil, _script} ->
        {:error, Error.invalid_error("Open a page before evaluating page state.")}

      {page, "document.title"} ->
        {:ok, session, %{result: page.title}}

      {page, "window.location.href"} ->
        {:ok, session, %{result: page.url}}

      {_page, _script} ->
        {:error, %Jido.Browser.Error.EvaluationError{message: "Unsupported simulated script", script: script}}
    end
  end

  defp current_page(%Session{} = session) do
    Map.get(session.connection || %{}, :current_page)
  end

  defp put_current_page(%Session{} = session, page) do
    connection =
      session.connection
      |> Map.put(:current_url, page.url)
      |> Map.put(:current_page, page)

    %{session | connection: connection}
  end

  defp find_link(page, selector, text) do
    page.links
    |> Enum.find(fn link ->
      selector_match? = link.selector == selector
      text_match? = is_nil(text) or link.text == text
      selector_match? and text_match?
    end)
    |> case do
      nil -> {:error, Error.element_error("click", selector, :link_not_found)}
      link -> {:ok, link}
    end
  end
end
