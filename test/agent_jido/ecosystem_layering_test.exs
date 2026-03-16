defmodule AgentJido.EcosystemLayeringTest do
  use ExUnit.Case, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering

  test "only jido resolves to the core layer" do
    public_packages = Ecosystem.public_packages()

    core_ids =
      public_packages
      |> Enum.filter(&(Layering.layer_for(&1) == :core))
      |> Enum.map(& &1.id)

    assert core_ids == ["jido"]
    assert Layering.layer_for(Ecosystem.get_package!("jido_harness")) == :app
    assert Layering.layer_for(Ecosystem.get_package!("jido_action")) == :foundation
    assert Layering.layer_for(Ecosystem.get_package!("jido_signal")) == :foundation
  end
end
