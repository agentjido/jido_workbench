defmodule AgentJido.Ecosystem.GraphAscii do
  @moduledoc """
  Builds a curated, deterministic ecosystem graph model for HTML rendering.

  Layer placement and package relationships are intentionally explicit to
  communicate architecture clearly, rather than inferred from dependency depth.
  """

  @short_desc_overrides %{
    "llm_db" => "model registry",
    "req_llm" => "LLM client",
    "jido_action" => "validation",
    "jido_signal" => "event bus",
    "jido" => "agent runtime",
    "jido_ai" => "agent intelligence",
    "jido_browser" => "browser automation",
    "ash_jido" => "Ash bridge",
    "jido_behaviortree" => "behavior trees",
    "jido_claude" => "Claude integration",
    "jido_code" => "coding assistant",
    "jido_runic" => "workflow engine",
    "jido_live_dashboard" => "observability",
    "jido_shell" => "terminal interface",
    "jido_vfs" => "virtual filesystem",
    "jido_sandbox" => "tool sandbox"
  }

  @layer_specs [
    %{
      id: :app,
      label: "APPLICATION LAYER",
      summary: "Workflows, integrations, and operator-facing tooling",
      rows: [
        ["jido_code", "jido_runic", "jido_live_dashboard"],
        ["jido_behaviortree", "jido_claude", "jido_sandbox", "ash_jido"]
      ]
    },
    %{
      id: :ai,
      label: "AI LAYER",
      summary: "Reasoning, model interaction, and autonomous behavior",
      rows: [
        ["jido_ai"],
        ["jido_browser", "req_llm", "llm_db"]
      ]
    },
    %{
      id: :core,
      label: "CORE LAYER",
      summary: "BEAM-native runtime orchestration",
      rows: [
        ["jido"]
      ]
    },
    %{
      id: :foundation,
      label: "FOUNDATION LAYER",
      summary: "Composable primitives used throughout the ecosystem",
      rows: [
        ["jido_action", "jido_signal", "jido_shell", "jido_vfs"]
      ]
    }
  ]

  @relationship_edges [
    {"jido_code", "jido"},
    {"jido_code", "jido_ai"},
    {"jido_runic", "jido"},
    {"jido_runic", "jido_ai"},
    {"jido_live_dashboard", "jido"},
    {"jido_behaviortree", "jido"},
    {"jido_claude", "jido"},
    {"ash_jido", "jido"},
    {"ash_jido", "jido_action"},
    {"jido_ai", "jido"},
    {"jido_ai", "jido_browser"},
    {"jido_ai", "req_llm"},
    {"jido_browser", "jido"},
    {"jido_browser", "jido_action"},
    {"req_llm", "llm_db"},
    {"jido", "jido_action"},
    {"jido", "jido_signal"}
  ]

  @type graph_node :: %{
          id: String.t(),
          name: String.t(),
          title: String.t(),
          short_desc: String.t(),
          layer: atom(),
          tier: integer(),
          deps: [String.t()]
        }

  @type graph_layer :: %{
          id: atom(),
          label: String.t(),
          summary: String.t(),
          rows: [[graph_node()]]
        }

  @type model :: %{
          nodes: [graph_node()],
          node_by_id: %{String.t() => graph_node()},
          edges: [{String.t(), String.t()}],
          layers: [graph_layer()],
          dependents_by_id: %{String.t() => [String.t()]}
        }

  @spec build_model([map()]) :: model()
  def build_model(packages) when is_list(packages) do
    package_by_id =
      packages
      |> Enum.reject(&is_nil(field(&1, :id)))
      |> Map.new(&{field(&1, :id), &1})

    public_ids = package_by_id |> Map.keys() |> MapSet.new()
    layout_layer_by_id = build_layout_layer_by_id()
    deps_by_id = build_deps_by_id(public_ids)

    nodes =
      package_by_id
      |> Enum.map(fn {id, pkg} ->
        %{
          id: id,
          name: field(pkg, :name) || id,
          title: field(pkg, :title) || field(pkg, :name) || id,
          short_desc: short_desc_for(pkg),
          layer: Map.get(layout_layer_by_id, id, :app),
          tier: field(pkg, :tier) || 99,
          deps: Map.get(deps_by_id, id, [])
        }
      end)
      |> Enum.sort_by(& &1.id)

    node_by_id = Map.new(nodes, &{&1.id, &1})

    edges =
      @relationship_edges
      |> Enum.filter(fn {from, to} ->
        MapSet.member?(public_ids, from) and MapSet.member?(public_ids, to)
      end)

    layers = build_layers(node_by_id)

    dependents_by_id =
      Enum.reduce(edges, %{}, fn {from, to}, acc ->
        Map.update(acc, to, [from], fn list -> [from | list] end)
      end)
      |> Map.new(fn {id, dependents} -> {id, dependents |> Enum.uniq() |> Enum.sort()} end)

    %{
      nodes: nodes,
      node_by_id: node_by_id,
      edges: edges,
      layers: layers,
      dependents_by_id: dependents_by_id
    }
  end

  defp build_layout_layer_by_id do
    Enum.reduce(@layer_specs, %{}, fn layer, acc ->
      Enum.reduce(layer.rows, acc, fn row, row_acc ->
        Enum.reduce(row, row_acc, fn id, inner -> Map.put(inner, id, layer.id) end)
      end)
    end)
  end

  defp build_deps_by_id(public_ids) do
    @relationship_edges
    |> Enum.filter(fn {from, to} ->
      MapSet.member?(public_ids, from) and MapSet.member?(public_ids, to)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
    |> Map.new(fn {id, deps} -> {id, deps |> Enum.uniq() |> Enum.sort()} end)
  end

  defp build_layers(node_by_id) do
    used =
      @layer_specs
      |> Enum.flat_map(&Enum.concat(&1.rows))
      |> MapSet.new()

    base_layers =
      Enum.map(@layer_specs, fn spec ->
        rows =
          spec.rows
          |> Enum.map(fn ids ->
            ids
            |> Enum.map(&Map.get(node_by_id, &1))
            |> Enum.reject(&is_nil/1)
          end)
          |> Enum.reject(&(&1 == []))

        %{id: spec.id, label: spec.label, summary: spec.summary, rows: rows}
      end)
      |> Enum.reject(&(&1.rows == []))

    extra_nodes =
      node_by_id
      |> Map.values()
      |> Enum.reject(&MapSet.member?(used, &1.id))
      |> Enum.sort_by(& &1.id)

    if extra_nodes == [] do
      base_layers
    else
      base_layers ++
        [
          %{
            id: :app,
            label: "ADDITIONAL PACKAGES",
            summary: "Public packages not yet placed in curated layer rows",
            rows: [extra_nodes]
          }
        ]
    end
  end

  defp short_desc_for(pkg) do
    id = field(pkg, :id)

    cond do
      is_binary(field(pkg, :graph_label)) and String.trim(field(pkg, :graph_label)) != "" ->
        field(pkg, :graph_label) |> String.trim() |> short_desc(30)

      is_binary(id) and Map.has_key?(@short_desc_overrides, id) ->
        Map.fetch!(@short_desc_overrides, id)

      true ->
        pkg
        |> field(:tagline)
        |> short_desc(30)
    end
  end

  defp short_desc(nil, _max_width), do: ""

  defp short_desc(text, max_width) when is_binary(text) do
    text
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
    |> String.replace(~r/[.,;:!?]+$/, "")
    |> truncate_label(max_width)
  end

  defp truncate_label(label, max_width) when is_binary(label) do
    cond do
      String.length(label) <= max_width ->
        label

      max_width <= 1 ->
        String.slice(label, 0, max_width)

      true ->
        String.slice(label, 0, max_width - 1) <> "…"
    end
  end

  defp field(map, key) when is_map(map), do: Map.get(map, key)
  defp field(_, _), do: nil
end
