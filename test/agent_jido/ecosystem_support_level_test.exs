defmodule AgentJido.EcosystemSupportLevelTest do
  use ExUnit.Case, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.SupportLevel

  test "exposes the canonical support levels in display order" do
    assert SupportLevel.levels() == [:stable, :beta, :experimental]

    assert Enum.map(SupportLevel.all(), & &1.label) == [
             "Stable",
             "Beta",
             "Experimental"
           ]
  end

  test "derives package support levels from existing ecosystem metadata" do
    assert Ecosystem.get_package!("req_llm").support_level == :stable
    assert Ecosystem.get_package!("jido").support_level == :stable
    assert Ecosystem.get_package!("ash_jido").support_level == :stable
    assert Ecosystem.get_package!("jido_behaviortree").support_level == :stable
    assert Ecosystem.get_package!("jido_character").support_level == :stable
    assert Ecosystem.get_package!("jido_memory").support_level == :stable
    assert Ecosystem.get_package!("jido_memory_os").support_level == :stable
    assert Ecosystem.get_package!("jido_mcp").support_level == :beta
    assert Ecosystem.get_package!("jido_messaging").support_level == :beta
  end

  test "aligns published package versions with the official ecosystem inventory" do
    assert Ecosystem.get_package!("jido").version == "2.1.0"
    assert Ecosystem.get_package!("jido_action").version == "2.1.1"
    assert Ecosystem.get_package!("jido_ai").version == "2.0.0"
    assert Ecosystem.get_package!("jido_browser").version == "2.0.0"
    assert Ecosystem.get_package!("llm_db").version == "2026.3.2"
    assert Ecosystem.get_package!("req_llm").version == "1.7.1"
  end

  test "groups public packages by support level" do
    stable_packages = Ecosystem.public_packages_by_support_level(:stable)

    assert stable_packages != []
    assert Enum.all?(stable_packages, &(&1.support_level == :stable))
  end

  test "exposes tech lead ownership metadata for public packages" do
    assert Ecosystem.get_package!("jido").tech_lead == "@mikehostetler"
    assert Ecosystem.get_package!("jido_memory_os").tech_lead == "@pcharbon70"
    assert Enum.all?(Ecosystem.public_packages(), &is_binary(&1.tech_lead))
  end
end
