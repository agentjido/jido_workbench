defmodule AgentJido.Demos.BrowserDocsScoutAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.BrowserDocsScout.SimulatedAdapter
  alias AgentJido.Demos.BrowserDocsScoutAgent
  alias Jido.Browser.Plugin

  test "mounts browser plugin state with the simulated adapter" do
    agent = BrowserDocsScoutAgent.new()
    browser = BrowserDocsScoutAgent.plugin_state(agent, Plugin)

    assert browser.adapter == SimulatedAdapter
    assert browser.session == nil
    assert browser.headless == true
  end

  test "runs the docs scout flow through browser wrapper actions" do
    agent = BrowserDocsScoutAgent.new()

    {agent, []} = BrowserDocsScoutAgent.open_page(agent, SimulatedAdapter.overview_url())
    assert agent.state.current_page.title == "Jido Browser Plugin Guide"
    assert BrowserDocsScoutAgent.plugin_state(agent, Plugin).session != nil

    {agent, []} = BrowserDocsScoutAgent.extract_current_page(agent)
    assert agent.state.extracted_content =~ "Jido Browser Plugin Guide"
    assert agent.state.content_length > 0

    {agent, []} =
      BrowserDocsScoutAgent.follow_link(
        agent,
        "a[data-doc-link='testing']",
        text: "Testing browser agents"
      )

    assert agent.state.current_page.title == "Testing Browser Agents"

    {agent, []} = BrowserDocsScoutAgent.capture_screenshot(agent)
    assert agent.state.screenshot.mime == "image/png"
    assert agent.state.screenshot.base64 != ""

    {agent, []} = BrowserDocsScoutAgent.reset_browser(agent)
    assert BrowserDocsScoutAgent.plugin_state(agent, Plugin).session == nil
    assert agent.state.current_page == %{}
    assert agent.state.screenshot == %{}
  end

  test "preserves browser session across multi-turn follow-up actions" do
    agent = BrowserDocsScoutAgent.new()

    {agent, []} = BrowserDocsScoutAgent.open_page(agent, SimulatedAdapter.overview_url())
    session_id = BrowserDocsScoutAgent.plugin_state(agent, Plugin).session.id
    first_url = agent.state.current_page.url

    {agent, []} = BrowserDocsScoutAgent.extract_current_page(agent)
    assert BrowserDocsScoutAgent.plugin_state(agent, Plugin).session.id == session_id
    assert agent.state.extracted_content =~ "Jido Browser Plugin Guide"

    {agent, []} =
      BrowserDocsScoutAgent.follow_link(
        agent,
        "a[data-doc-link='testing']",
        text: "Testing browser agents"
      )

    assert BrowserDocsScoutAgent.plugin_state(agent, Plugin).session.id == session_id
    assert agent.state.current_page.title == "Testing Browser Agents"
    assert agent.state.current_page.url != first_url
  end
end
