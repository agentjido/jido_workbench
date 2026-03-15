defmodule AgentJido.Demos.WeatherReasoningStrategySuite.ComparisonLab do
  @moduledoc """
  Deterministic comparison harness for the weather reasoning strategy suite.
  """

  alias AgentJido.Demos.WeatherReasoningStrategySuite.Fixtures

  defstruct selected_preset_id: nil,
            selected_preset: nil,
            selected_strategy_id: nil,
            selected_strategy: nil,
            log: []

  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type t :: %__MODULE__{
          selected_preset_id: String.t(),
          selected_preset: Fixtures.preset(),
          selected_strategy_id: atom(),
          selected_strategy: Fixtures.strategy_entry(),
          log: [log_entry()]
        }

  @doc "Returns the deterministic preset catalog shown in the lab."
  @spec presets() :: [Fixtures.preset()]
  def presets, do: Fixtures.catalog()

  @doc "Creates a new comparison lab state."
  @spec new(String.t() | nil) :: t()
  def new(preset_id \\ nil) do
    preset = Fixtures.fetch!(preset_id)
    strategy_id = preset.recommendation.strategy_id

    %__MODULE__{
      selected_preset_id: preset.id,
      selected_preset: preset,
      selected_strategy_id: strategy_id,
      selected_strategy: Fixtures.strategy!(preset, strategy_id),
      log: [log_entry("Loaded", "Opened #{preset.title} with #{preset.recommendation.label} preselected.")]
    }
  end

  @doc "Changes the selected preset and resets the selected strategy to the recommended one."
  @spec select_preset(t(), String.t()) :: t()
  def select_preset(%__MODULE__{} = lab, preset_id) do
    preset = Fixtures.fetch!(preset_id)
    strategy_id = preset.recommendation.strategy_id

    %{
      lab
      | selected_preset_id: preset.id,
        selected_preset: preset,
        selected_strategy_id: strategy_id,
        selected_strategy: Fixtures.strategy!(preset, strategy_id),
        log: [
          log_entry("Scenario", "Loaded #{preset.title}. Recommended starting point: #{preset.recommendation.label}.")
          | lab.log
        ]
    }
    |> cap_log()
  end

  @doc "Selects a specific strategy within the active preset."
  @spec select_strategy(t(), atom() | String.t()) :: t()
  def select_strategy(%__MODULE__{} = lab, strategy_id) when is_binary(strategy_id) do
    select_strategy(lab, String.to_existing_atom(strategy_id))
  end

  def select_strategy(%__MODULE__{} = lab, strategy_id) when is_atom(strategy_id) do
    strategy = Fixtures.strategy!(lab.selected_preset, strategy_id)

    %{
      lab
      | selected_strategy_id: strategy_id,
        selected_strategy: strategy,
        log: [
          log_entry("Strategy", "Focused #{strategy.name} for the #{lab.selected_preset.title} scenario.")
          | lab.log
        ]
    }
    |> cap_log()
  end

  defp cap_log(%__MODULE__{} = lab) do
    %{lab | log: Enum.take(lab.log, 12)}
  end

  defp log_entry(label, detail), do: %{label: label, detail: detail}
end
