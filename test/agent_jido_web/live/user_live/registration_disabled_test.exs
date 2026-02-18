defmodule AgentJidoWeb.UserLive.RegistrationDisabledTest do
  use AgentJidoWeb.ConnCase, async: true

  describe "registration route" do
    test "is not available", %{conn: conn} do
      conn = get(conn, "/users/register")
      assert response(conn, 404)
    end
  end
end
