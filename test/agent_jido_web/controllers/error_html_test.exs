defmodule AgentJidoWeb.ErrorHTMLTest do
  use AgentJidoWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    body = render_to_string(AgentJidoWeb.ErrorHTML, "404", "html", [])

    assert body =~ "Page not found"
    assert body =~ "GET BUILDING"
  end

  test "renders 500.html" do
    assert render_to_string(AgentJidoWeb.ErrorHTML, "500", "html", []) ==
             "Internal Server Error"
  end
end
