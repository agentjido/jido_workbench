defmodule AgentJidoWeb.Jido.NavTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.Jido.Nav

  describe "jido_version/1" do
    test "falls back when no version is available" do
      assert Nav.jido_version(nil) == "2.0.0-rc.5"
    end

    test "normalizes charlist and binary versions" do
      assert Nav.jido_version(~c"2.0.0-rc.5") == "2.0.0-rc.5"
      assert Nav.jido_version("2.0.0-rc.5") == "2.0.0-rc.5"
    end
  end

  test "jido_version/0 returns a non-empty runtime version" do
    assert Nav.jido_version() != ""
  end

  test "primary nav links exclude retired training/search routes" do
    links = Nav.primary_nav_links()
    hrefs = Enum.map(links, &elem(&1, 1))

    assert links == [
             {"Features", "/features"},
             {"Ecosystem", "/ecosystem"},
             {"Examples", "/examples"},
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
