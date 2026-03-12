defmodule AgentJido.Demos.BrowserDocsScoutAgent do
  @moduledoc """
  Copy-pasteable browser docs scout agent built on `Jido.Browser.Plugin`.

  The example uses a simulated adapter in this repo so the demo stays
  deterministic, but the agent shape is the same one users can lift into
  their own projects and point at a real browser adapter later.
  """

  alias AgentJido.Demos.BrowserDocsScout.Actions.{
    CaptureScreenshotAction,
    ExtractPageContentAction,
    FollowLinkAction,
    OpenPageAction,
    ResetBrowserAction
  }

  alias AgentJido.Demos.BrowserDocsScout.SimulatedAdapter
  alias Jido.Agent

  use Jido.Agent,
    name: "browser_docs_scout_agent",
    description: "Navigates documentation pages with Jido.Browser and captures deterministic outputs",
    schema: [
      current_page: [type: :map, default: %{}],
      extracted_content: [type: :string, default: ""],
      extracted_format: [type: :string, default: ""],
      content_length: [type: :integer, default: 0],
      screenshot: [type: :map, default: %{}],
      last_step: [type: :string, default: "idle"]
    ],
    plugins: [
      {Jido.Browser.Plugin,
       %{
         adapter: SimulatedAdapter,
         headless: true,
         timeout: 5_000,
         viewport: %{width: 1440, height: 900}
       }}
    ],
    signal_routes: [
      {"browser.docs.open", OpenPageAction},
      {"browser.docs.follow_link", FollowLinkAction},
      {"browser.docs.extract", ExtractPageContentAction},
      {"browser.docs.screenshot", CaptureScreenshotAction},
      {"browser.docs.reset", ResetBrowserAction}
    ]

  @spec open_page(Agent.t(), String.t()) :: Agent.cmd_result()
  def open_page(%Agent{} = agent, url) when is_binary(url) do
    cmd(agent, {OpenPageAction, %{url: url}})
  end

  @spec follow_link(Agent.t(), String.t(), keyword()) :: Agent.cmd_result()
  def follow_link(%Agent{} = agent, selector, opts \\ []) when is_binary(selector) do
    params =
      opts
      |> Enum.into(%{})
      |> Map.put(:selector, selector)

    cmd(agent, {FollowLinkAction, params})
  end

  @spec extract_current_page(Agent.t(), keyword()) :: Agent.cmd_result()
  def extract_current_page(%Agent{} = agent, opts \\ []) do
    cmd(agent, {ExtractPageContentAction, Enum.into(opts, %{})})
  end

  @spec capture_screenshot(Agent.t(), keyword()) :: Agent.cmd_result()
  def capture_screenshot(%Agent{} = agent, opts \\ []) do
    cmd(agent, {CaptureScreenshotAction, Enum.into(opts, %{})})
  end

  @spec reset_browser(Agent.t()) :: Agent.cmd_result()
  def reset_browser(%Agent{} = agent) do
    cmd(agent, ResetBrowserAction)
  end
end
