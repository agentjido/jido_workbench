defmodule AgentJidoWeb.JidoTrainingModuleLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders module detail and previous/next links", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/training/signals-routing")

    assert html =~ "Signals, Routing, and Agent Communication"
    assert html =~ "Lesson Breakdown"
    assert html =~ "Previous Module"
    assert html =~ "Next Module"
    assert html =~ ~s(href="/training/actions-validation")
    assert html =~ ~s(href="/training/directives-scheduling")
  end

  test "unknown slug returns 404", %{conn: conn} do
    assert_raise AgentJido.Training.NotFoundError, fn ->
      live(conn, "/training/not-a-real-module")
    end
  end
end
