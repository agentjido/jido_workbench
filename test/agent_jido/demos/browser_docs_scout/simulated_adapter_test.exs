defmodule AgentJido.Demos.BrowserDocsScout.SimulatedAdapterTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.BrowserDocsScout.SimulatedAdapter

  test "navigates between deterministic fixture pages" do
    session = SimulatedAdapter.start_session(viewport: %{width: 1200, height: 800})

    assert session.connection.current_url == nil

    {:ok, session, result} = SimulatedAdapter.navigate(session, SimulatedAdapter.overview_url(), [])

    assert result.title == "Jido Browser Plugin Guide"
    assert session.connection.current_page.title == "Jido Browser Plugin Guide"

    {:ok, session, click_result} =
      SimulatedAdapter.click(session, "a[data-doc-link='testing']", text: "Testing browser agents")

    assert click_result.title == "Testing Browser Agents"
    assert session.connection.current_url == SimulatedAdapter.testing_url()
  end

  test "extracts markdown content and returns a png screenshot" do
    session = SimulatedAdapter.start_session([])
    {:ok, session, _} = SimulatedAdapter.navigate(session, SimulatedAdapter.overview_url(), [])

    {:ok, _session, extract_result} =
      SimulatedAdapter.extract_content(session, selector: "article", format: :markdown)

    assert extract_result.format == :markdown
    assert extract_result.content =~ "Jido Browser Plugin Guide"
    assert extract_result.content =~ "Jido.Browser.Plugin"

    {:ok, _session, screenshot_result} = SimulatedAdapter.screenshot(session, full_page: true)

    assert screenshot_result.mime == "image/png"
    assert byte_size(screenshot_result.bytes) > 0
  end
end
