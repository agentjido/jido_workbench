defmodule AgentJido.Ecosystem.GraphAsciiTest do
  use ExUnit.Case, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.GraphAscii

  describe "build_model/1" do
    test "builds nodes/edges and drops unknown packages from explicit relationships" do
      model = GraphAscii.build_model(sample_packages())

      assert MapSet.new(Enum.map(model.nodes, & &1.id)) ==
               MapSet.new(["jido_action", "jido_signal", "jido", "jido_ai", "req_llm"])

      assert MapSet.new(model.edges) ==
               MapSet.new([
                 {"jido", "jido_action"},
                 {"jido", "jido_signal"},
                 {"jido_ai", "jido"},
                 {"jido_ai", "req_llm"}
               ])
    end

    test "uses curated relationships instead of package ecosystem_deps for edge derivation" do
      model = GraphAscii.build_model(sample_packages())

      # jido has empty ecosystem_deps in sample input but curated graph keeps these edges.
      assert {"jido", "jido_action"} in model.edges
      assert {"jido", "jido_signal"} in model.edges

      # req_llm -> llm_db is curated but llm_db is not present in sample input.
      refute {"req_llm", "llm_db"} in model.edges
    end
  end

  describe "curated layers" do
    test "renders layers in top-down order with support for multiple rows" do
      model = GraphAscii.build_model(Ecosystem.public_packages())

      assert Enum.map(model.layers, & &1.id) == [:app, :ai, :core, :foundation]

      app_layer = Enum.find(model.layers, &(&1.id == :app))
      ai_layer = Enum.find(model.layers, &(&1.id == :ai))

      assert length(app_layer.rows) == 2
      assert length(ai_layer.rows) == 2
    end

    test "places sandbox in application and shell/vfs in foundation when present" do
      packages = [
        %{id: "jido_sandbox", name: "jido_sandbox", title: "Jido Sandbox", tagline: "sandbox"},
        %{id: "jido_shell", name: "jido_shell", title: "Jido Shell", tagline: "shell"},
        %{id: "jido_vfs", name: "jido_vfs", title: "Jido VFS", tagline: "vfs"}
      ]

      model = GraphAscii.build_model(packages)

      layer_rows =
        model.layers
        |> Enum.flat_map(fn layer ->
          Enum.flat_map(layer.rows, fn row ->
            Enum.map(row, fn node -> {node.id, layer.id} end)
          end)
        end)
        |> Map.new()

      assert layer_rows["jido_sandbox"] == :app
      assert layer_rows["jido_shell"] == :foundation
      assert layer_rows["jido_vfs"] == :foundation
    end

    test "every public package is present in one of the curated layer rows" do
      model = GraphAscii.build_model(Ecosystem.public_packages())

      laid_out_ids =
        model.layers
        |> Enum.flat_map(& &1.rows)
        |> List.flatten()
        |> Enum.map(& &1.id)
        |> MapSet.new()

      public_ids =
        Ecosystem.public_packages()
        |> Enum.map(& &1.id)
        |> MapSet.new()

      assert laid_out_ids == public_ids
    end
  end

  test "real ecosystem includes llm_db -> req_llm -> jido_ai chain" do
    model = GraphAscii.build_model(Ecosystem.public_packages())

    assert {"req_llm", "llm_db"} in model.edges
    assert {"jido_ai", "req_llm"} in model.edges
  end

  defp sample_packages do
    [
      %{
        id: "jido_ai",
        name: "jido_ai",
        title: "Jido AI",
        tagline: "LLM orchestration and tools",
        category: :ai,
        tier: 1,
        ecosystem_deps: []
      },
      %{
        id: "req_llm",
        name: "req_llm",
        title: "ReqLLM",
        tagline: "HTTP client for LLM APIs",
        category: :ai,
        tier: 1,
        ecosystem_deps: []
      },
      %{
        id: "jido",
        name: "jido",
        title: "Jido",
        tagline: "Core agent framework",
        category: :core,
        tier: 1,
        ecosystem_deps: []
      },
      %{
        id: "jido_action",
        name: "jido_action",
        title: "Jido Action",
        tagline: "Schema-based validation",
        category: :core,
        tier: 1,
        ecosystem_deps: []
      },
      %{
        id: "jido_signal",
        name: "jido_signal",
        title: "Jido Signal",
        tagline: "Pub/Sub signaling",
        category: :core,
        tier: 1,
        ecosystem_deps: []
      }
    ]
  end
end
