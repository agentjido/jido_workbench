defmodule AgentJidoWeb.JidoExamplesLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Examples

  @hidden_slug "budget-guardrail-agent"

  test "unpublished examples are not listed on /examples", %{conn: conn} do
    hidden = Examples.get_example!(@hidden_slug, include_unpublished: true)
    {:ok, _view, html} = live(conn, "/examples")

    refute html =~ hidden.title
  end

  test "unpublished examples are not routable on /examples/:slug", %{conn: conn} do
    assert_raise AgentJido.Examples.NotFoundError, fn ->
      live(conn, "/examples/#{@hidden_slug}")
    end
  end
end
