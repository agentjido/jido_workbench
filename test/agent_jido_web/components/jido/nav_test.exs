defmodule AgentJidoWeb.Jido.NavTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.Jido.Nav

  describe "jido_version/1" do
    test "falls back when no version is available" do
      assert Nav.jido_version(nil) == "unknown"
    end

    test "normalizes charlist and binary versions" do
      assert Nav.jido_version(~c"2.1.3") == "2.1.3"
      assert Nav.jido_version("2.1.3") == "2.1.3"
    end
  end

  test "jido_version/0 reads installed jido application version" do
    expected_vsn =
      case Application.spec(:jido, :vsn) do
        nil ->
          _ = Application.load(:jido)
          Application.spec(:jido, :vsn)

        vsn ->
          vsn
      end

    assert Nav.jido_version() == Nav.jido_version(expected_vsn)
    refute Nav.jido_version() == "unknown"
  end

  test "primary nav links exclude retired training/search routes" do
    links = Nav.primary_nav_links()
    hrefs = Enum.map(links, &elem(&1, 1))

    assert links == [
             {"Features", "/features"},
             {"Ecosystem", "/ecosystem"},
             {"Examples", "/examples"},
             {"Community", "/community"},
             {"Docs", "/docs"}
           ]

    refute "/training" in hrefs
    refute "/search" in hrefs
  end

  test "footer resource links exclude retired training/search routes" do
    hrefs = Nav.footer_resource_links() |> Enum.map(&elem(&1, 1))

    refute "/training" in hrefs
    refute "/search" in hrefs
  end
end
