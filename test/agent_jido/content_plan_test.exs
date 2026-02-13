defmodule AgentJido.ContentPlanTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentPlan

  @training_entries [
    "training/agent-fundamentals",
    "training/actions-validation",
    "training/signals-routing",
    "training/directives-scheduling",
    "training/liveview-integration",
    "training/production-readiness"
  ]

  @feature_entries [
    "features/beam-native-agent-model",
    "features/schema-validated-actions",
    "features/signal-routing-and-coordination",
    "features/directives-and-scheduling",
    "features/liveview-integration-patterns",
    "features/composable-ecosystem",
    "features/supervision-and-fault-isolation",
    "features/production-telemetry"
  ]

  test "content plan includes training and features sections" do
    section_ids = Enum.map(ContentPlan.all_sections(), & &1.id)

    assert "training" in section_ids
    assert "features" in section_ids
  end

  test "content plan includes all training and features entries" do
    entry_ids = Enum.map(ContentPlan.all_entries(), & &1.id)

    for id <- @training_entries do
      assert id in entry_ids
    end

    for id <- @feature_entries do
      assert id in entry_ids
    end
  end
end
