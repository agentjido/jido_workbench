defmodule AgentJido.Demos.ActionsRuntime.ConvertTemperatureAction do
  @moduledoc """
  Deterministic temperature conversion tool used by the actions runtime demo.
  """

  use Jido.Action,
    name: "convert_temperature",
    description: "Convert a temperature between Fahrenheit and Celsius",
    category: "ai",
    tags: ["tool", "temperature", "deterministic"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        value: Zoi.float(description: "Temperature value to convert"),
        from: Zoi.string(description: "Source unit (`fahrenheit` or `celsius`)"),
        to: Zoi.string(description: "Target unit (`fahrenheit` or `celsius`)")
      })

  @impl true
  def run(params, _context) do
    value = params[:value]
    from = normalize_unit(params[:from])
    to = normalize_unit(params[:to])

    with {:ok, from} <- validate_unit(from),
         {:ok, to} <- validate_unit(to) do
      converted_value =
        case {from, to} do
          {:fahrenheit, :celsius} -> (value - 32.0) * 5.0 / 9.0
          {:celsius, :fahrenheit} -> value * 9.0 / 5.0 + 32.0
          _same -> value
        end

      {:ok,
       %{
         input_value: value,
         input_unit: Atom.to_string(from),
         converted_value: Float.round(converted_value, 1),
         output_unit: Atom.to_string(to),
         formula: formula_for(from, to)
       }}
    end
  end

  defp normalize_unit(unit) when is_binary(unit) do
    unit
    |> String.downcase()
    |> String.trim()
    |> String.to_atom()
  end

  defp normalize_unit(unit) when is_atom(unit), do: unit
  defp normalize_unit(_other), do: :invalid

  defp validate_unit(unit) when unit in [:fahrenheit, :celsius], do: {:ok, unit}
  defp validate_unit(_unit), do: {:error, :unsupported_temperature_unit}

  defp formula_for(:fahrenheit, :celsius), do: "(F - 32) * 5 / 9"
  defp formula_for(:celsius, :fahrenheit), do: "(C * 9 / 5) + 32"
  defp formula_for(_from, _to), do: "identity"
end
