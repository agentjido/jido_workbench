defmodule AgentJidoWeb.JidoSkillsLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the vendored upstream skills catalog page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/skills")

    assert html =~ "Package skills for contributors and adopters"
    assert html =~ "one card per external package skill"
    assert html =~ "Router Skill"
    assert html =~ "jido-skill-router"
    assert html =~ "jido-action"
    assert html =~ "req-llm"
    assert html =~ ~s(href="https://github.com/arrowcircle/jido-skills")
    assert html =~ ~s(href="/examples/jido-ai-skills-runtime-foundations?tab=demo")
    assert html =~ ~s(href="/ecosystem/req_llm")
    assert html =~ ~s(href="/skills")
  end
end
