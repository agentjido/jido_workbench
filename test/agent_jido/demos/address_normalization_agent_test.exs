defmodule AgentJido.Demos.AddressNormalizationAgentTest do
  use ExUnit.Case, async: false

  alias AgentJido.Demos.AddressNormalization.{ExecuteAction, ResetAction}
  alias AgentJido.Demos.AddressNormalizationAgent

  @valid_payload %{
    line1: " 123   main st ",
    city: "san francisco",
    region: "california",
    postal_code: "94105-1234",
    country: "us"
  }

  setup_all do
    ensure_started(:telemetry)
    ensure_started(:jido_action)

    :ok
  end

  defp ensure_started(app) do
    case Application.ensure_all_started(app) do
      {:ok, _apps} -> :ok
      {:error, {:already_started, _app}} -> :ok
      {:error, reason} -> raise "failed to start #{inspect(app)}: #{inspect(reason)}"
    end
  end

  describe "AddressNormalizationAgent.new/0" do
    test "creates agent with default state" do
      agent = AddressNormalizationAgent.new()
      assert agent.state.normalized_address == ""
      assert agent.state.last_status == :idle
      assert agent.state.successful_runs == 0
    end
  end

  describe "ExecuteAction" do
    test "normalizes a valid payload into canonical fields" do
      agent = AddressNormalizationAgent.new()
      {agent, directives} = AddressNormalizationAgent.cmd(agent, {ExecuteAction, @valid_payload})

      assert directives == []
      assert agent.state.last_status == :ok
      assert agent.state.successful_runs == 1
      assert agent.state.normalized.line1 == "123 Main St"
      assert agent.state.normalized.city == "San Francisco"
      assert agent.state.normalized.region == "CA"
      assert agent.state.normalized.postal_code == "94105"
      assert agent.state.normalized.country == "US"
      assert agent.state.normalized_address == "123 Main St, San Francisco, CA 94105, US"
    end

    test "returns error directive when custom validation fails" do
      payload = %{line1: "123 Main St", city: "Austin", region: "TX", postal_code: "78701", country: "ca"}
      original = AddressNormalizationAgent.new()

      {agent, directives} = AddressNormalizationAgent.cmd(original, {ExecuteAction, payload})

      assert agent.state == original.state
      assert Enum.any?(directives, &match?(%Jido.Agent.Directive.Error{}, &1))
    end

    test "returns error directive when required contract fields are missing" do
      payload = Map.delete(@valid_payload, :postal_code)
      original = AddressNormalizationAgent.new()

      {agent, directives} = AddressNormalizationAgent.cmd(original, {ExecuteAction, payload})

      assert agent.state == original.state
      assert Enum.any?(directives, &match?(%Jido.Agent.Directive.Error{}, &1))
    end
  end

  describe "ResetAction" do
    test "resets normalized state" do
      agent = AddressNormalizationAgent.new()
      {agent, _} = AddressNormalizationAgent.cmd(agent, {ExecuteAction, @valid_payload})
      {agent, directives} = AddressNormalizationAgent.cmd(agent, ResetAction)

      assert directives == []
      assert agent.state.last_input == %{}
      assert agent.state.normalized == %{}
      assert agent.state.normalized_address == ""
      assert agent.state.last_status == :idle
      assert agent.state.successful_runs == 0
    end
  end

  describe "signal_routes/1" do
    test "maps address signals to actions" do
      routes = AddressNormalizationAgent.signal_routes(%{})

      assert {"address.normalize.execute", ExecuteAction} in routes
      assert {"address.normalize.reset", ResetAction} in routes
    end
  end
end
