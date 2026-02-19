defmodule AgentJido.Demos.AddressNormalization.ExecuteAction do
  @moduledoc """
  Validates and normalizes US-style address fields into a canonical string.
  """
  use Jido.Action,
    name: "address_normalization_execute",
    description: "Validates address contracts and returns canonical components",
    schema: [
      line1: [type: :string, required: true, doc: "Street line, e.g. 123 Main St"],
      city: [type: :string, required: true, doc: "City name"],
      region: [type: :string, required: true, doc: "State or region"],
      postal_code: [type: :string, required: true, doc: "Postal code"],
      country: [type: :string, required: true, doc: "Country code, must normalize to US"]
    ]

  @region_map %{
    "CALIFORNIA" => "CA",
    "CA" => "CA",
    "NEW YORK" => "NY",
    "NY" => "NY",
    "TEXAS" => "TX",
    "TX" => "TX",
    "WASHINGTON" => "WA",
    "WA" => "WA",
    "ILLINOIS" => "IL",
    "IL" => "IL"
  }

  @impl true
  def run(params, context) do
    with {:ok, postal_code} <- normalize_postal_code(params.postal_code),
         {:ok, country} <- normalize_country(params.country) do
      line1 = params.line1 |> normalize_whitespace() |> title_case()
      city = params.city |> normalize_whitespace() |> title_case()
      region = params.region |> normalize_region()

      normalized = %{
        line1: line1,
        city: city,
        region: region,
        postal_code: postal_code,
        country: country
      }

      normalized_address = "#{line1}, #{city}, #{region} #{postal_code}, #{country}"
      successful_runs = Map.get(context.state, :successful_runs, 0) + 1

      {:ok,
       %{
         last_input: params,
         normalized: normalized,
         normalized_address: normalized_address,
         last_status: :ok,
         validation_errors: [],
         successful_runs: successful_runs
       }}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp normalize_postal_code(postal_code) do
    digits = Regex.replace(~r/\D/, postal_code, "")

    case String.length(digits) do
      length when length >= 5 -> {:ok, String.slice(digits, 0, 5)}
      _ -> {:error, "postal_code must include at least 5 digits"}
    end
  end

  defp normalize_country(country) do
    normalized =
      country
      |> normalize_whitespace()
      |> String.upcase()

    case normalized do
      "US" -> {:ok, "US"}
      "USA" -> {:ok, "US"}
      _ -> {:error, "country must be US or USA"}
    end
  end

  defp normalize_region(region) do
    normalized =
      region
      |> normalize_whitespace()
      |> String.upcase()

    Map.get(@region_map, normalized, normalized)
  end

  defp normalize_whitespace(value) do
    value
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp title_case(value) do
    value
    |> String.split(" ", trim: true)
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
