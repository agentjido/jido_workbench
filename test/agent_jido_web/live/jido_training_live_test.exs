defmodule AgentJidoWeb.JidoTrainingLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Training

  test "renders training landing page with curriculum modules", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/training")

    assert html =~ "TRAINING TRACK"
    assert html =~ "Practical Jido training for"

    for module <- Training.all_modules() do
      assert html =~ module.title
    end
  end

  test "module cards link to training detail pages", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/training")

    for module <- Training.all_modules() do
      assert html =~ ~s(href="/training/#{module.slug}")
    end
  end
end
