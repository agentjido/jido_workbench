defmodule AgentJido.Demos.BrowserDocsScout.ActionHelpers do
  @moduledoc false

  alias Jido.Browser
  alias Jido.Browser.Error
  alias Jido.Browser.Session

  @spec browser_state(map()) :: map()
  def browser_state(context) when is_map(context) do
    get_in(context, [:state, :browser]) || %{}
  end

  @spec ensure_session(map()) :: {:ok, Session.t()} | {:error, term()}
  def ensure_session(context) when is_map(context) do
    case Map.get(browser_state(context), :session) do
      %Session{} = session ->
        {:ok, session}

      nil ->
        start_session(browser_state(context))
    end
  end

  @spec require_session(map(), String.t()) :: {:ok, Session.t()} | {:error, term()}
  def require_session(context, message) when is_binary(message) do
    case Map.get(browser_state(context), :session) do
      %Session{} = session -> {:ok, session}
      nil -> {:error, Error.invalid_error(message)}
    end
  end

  @spec page_from_session(Session.t()) :: map()
  def page_from_session(%Session{} = session) do
    Map.get(session.connection || %{}, :current_page, %{})
  end

  @spec browser_attrs(Session.t()) :: map()
  def browser_attrs(%Session{} = session) do
    current_page = page_from_session(session)

    %{
      session: session,
      last_url: Map.get(session.connection || %{}, :current_url),
      last_title: Map.get(current_page, :title)
    }
  end

  @spec reset_browser_attrs(map()) :: map()
  def reset_browser_attrs(browser_state) when is_map(browser_state) do
    browser_state
    |> Map.put(:session, nil)
    |> Map.put(:last_url, nil)
    |> Map.put(:last_title, nil)
  end

  defp start_session(browser_state) do
    opts =
      [
        adapter: Map.get(browser_state, :adapter),
        headless: Map.get(browser_state, :headless, true),
        timeout: Map.get(browser_state, :timeout, 30_000),
        viewport: Map.get(browser_state, :viewport)
      ]
      |> Enum.reject(fn {_key, value} -> is_nil(value) end)

    Browser.start_session(opts)
  end
end

defmodule AgentJido.Demos.BrowserDocsScout.Actions.OpenPageAction do
  @moduledoc """
  Open a documentation page, starting a browser session when needed.
  """

  use Jido.Action,
    name: "browser_docs_open_page",
    description: "Open a docs page using the browser plugin session",
    schema: [
      url: [type: :string, required: true, doc: "Docs page URL to open"]
    ]

  alias AgentJido.Demos.BrowserDocsScout.ActionHelpers
  alias Jido.Agent.StateOp
  alias Jido.Browser.Actions.Navigate

  @impl true
  def run(params, context) do
    with {:ok, session} <- ActionHelpers.ensure_session(context),
         {:ok, result} <- Navigate.run(%{url: params.url}, %{session: session}) do
      updated_session = result.session
      current_page = ActionHelpers.page_from_session(updated_session)

      {:ok,
       %{
         browser: ActionHelpers.browser_attrs(updated_session),
         current_page: %{
           url: Map.get(current_page, :url, params.url),
           title: Map.get(current_page, :title, "Docs page"),
           description: Map.get(current_page, :description, ""),
           selector: "article",
           available_links: Enum.map(Map.get(current_page, :links, []), &Map.take(&1, [:text, :href]))
         },
         extracted_content: "",
         extracted_format: "",
         content_length: 0,
         last_step: "opened_page"
       }, [%StateOp.SetPath{path: [:screenshot], value: %{}}]}
    end
  end
end

defmodule AgentJido.Demos.BrowserDocsScout.Actions.FollowLinkAction do
  @moduledoc """
  Follow a link on the current page using the active browser session.
  """

  use Jido.Action,
    name: "browser_docs_follow_link",
    description: "Follow a documentation link from the current page",
    schema: [
      selector: [type: :string, required: true, doc: "CSS selector for the link to follow"],
      text: [type: :string, doc: "Optional text match for the link"]
    ]

  alias AgentJido.Demos.BrowserDocsScout.ActionHelpers
  alias Jido.Agent.StateOp
  alias Jido.Browser.Actions.Click

  @impl true
  def run(params, context) do
    with {:ok, session} <-
           ActionHelpers.require_session(context, "Open a docs page before following a link."),
         {:ok, result} <- Click.run(Map.take(params, [:selector, :text]), %{session: session}) do
      updated_session = result.session
      current_page = ActionHelpers.page_from_session(updated_session)

      {:ok,
       %{
         browser: ActionHelpers.browser_attrs(updated_session),
         current_page: %{
           url: Map.get(current_page, :url),
           title: Map.get(current_page, :title, "Docs page"),
           description: Map.get(current_page, :description, ""),
           selector: "article",
           available_links: Enum.map(Map.get(current_page, :links, []), &Map.take(&1, [:text, :href]))
         },
         extracted_content: "",
         extracted_format: "",
         content_length: 0,
         last_step: "followed_link"
       }, [%StateOp.SetPath{path: [:screenshot], value: %{}}]}
    end
  end
end

defmodule AgentJido.Demos.BrowserDocsScout.Actions.ExtractPageContentAction do
  @moduledoc """
  Extract the current page content as markdown using the active session.
  """

  use Jido.Action,
    name: "browser_docs_extract_page_content",
    description: "Extract markdown content from the active docs page",
    schema: [
      selector: [type: :string, default: "article", doc: "Selector to scope extraction"],
      format: [type: {:in, [:markdown, :html]}, default: :markdown, doc: "Output format"]
    ]

  alias AgentJido.Demos.BrowserDocsScout.ActionHelpers
  alias Jido.Agent.StateOp
  alias Jido.Browser.Actions.ExtractContent

  @impl true
  def run(params, context) do
    with {:ok, session} <-
           ActionHelpers.require_session(context, "Open a docs page before extracting content."),
         {:ok, result} <- ExtractContent.run(params, %{session: session}) do
      updated_session = result.session

      {:ok,
       %{
         browser: ActionHelpers.browser_attrs(updated_session),
         extracted_content: result.content,
         extracted_format: Atom.to_string(result.format),
         content_length: result.length,
         last_step: "extracted_content"
       }, [%StateOp.SetPath{path: [:screenshot], value: %{}}]}
    end
  end
end

defmodule AgentJido.Demos.BrowserDocsScout.Actions.CaptureScreenshotAction do
  @moduledoc """
  Capture a screenshot for the current documentation page.
  """

  use Jido.Action,
    name: "browser_docs_capture_screenshot",
    description: "Capture a deterministic screenshot for the active docs page",
    schema: [
      full_page: [type: :boolean, default: true, doc: "Capture the full page"]
    ]

  alias AgentJido.Demos.BrowserDocsScout.ActionHelpers
  alias Jido.Browser.Actions.Screenshot

  @impl true
  def run(params, context) do
    with {:ok, session} <-
           ActionHelpers.require_session(context, "Open a docs page before capturing a screenshot."),
         {:ok, result} <- Screenshot.run(params, %{session: session}) do
      updated_session = result.session

      {:ok,
       %{
         browser: ActionHelpers.browser_attrs(updated_session),
         screenshot: %{
           mime: result.mime,
           size: result.size,
           base64: result.base64
         },
         last_step: "captured_screenshot"
       }}
    end
  end
end

defmodule AgentJido.Demos.BrowserDocsScout.Actions.ResetBrowserAction do
  @moduledoc """
  End the active browser session and clear demo state.
  """

  use Jido.Action,
    name: "browser_docs_reset_browser",
    description: "Reset the browser session and clear extracted outputs"

  alias AgentJido.Demos.BrowserDocsScout.ActionHelpers
  alias Jido.Agent.StateOp
  alias Jido.Browser

  @impl true
  def run(_params, context) do
    browser_state = ActionHelpers.browser_state(context)

    case Map.get(browser_state, :session) do
      nil ->
        {:ok,
         %{
           browser: ActionHelpers.reset_browser_attrs(browser_state),
           extracted_content: "",
           extracted_format: "",
           content_length: 0,
           last_step: "reset_browser"
         },
         [
           %StateOp.SetPath{path: [:current_page], value: %{}},
           %StateOp.SetPath{path: [:screenshot], value: %{}}
         ]}

      session ->
        :ok = Browser.end_session(session)

        {:ok,
         %{
           browser: ActionHelpers.reset_browser_attrs(browser_state),
           extracted_content: "",
           extracted_format: "",
           content_length: 0,
           last_step: "reset_browser"
         },
         [
           %StateOp.SetPath{path: [:current_page], value: %{}},
           %StateOp.SetPath{path: [:screenshot], value: %{}}
         ]}
    end
  end
end
