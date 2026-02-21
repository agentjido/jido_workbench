defmodule AgentJido.ContentGen.Selection do
  @moduledoc """
  Deterministic selection/filtering of content-plan entries for generation runs.
  """

  alias AgentJido.ContentPlan

  @spec select(map(), [struct()]) :: [struct()]
  def select(opts, entries \\ ContentPlan.all_entries()) do
    max_entries = opts[:max] || AgentJido.ContentGen.default_batch_size()
    section_filters = opts |> Map.get(:sections, []) |> List.wrap() |> MapSet.new()
    status_filters = opts |> Map.get(:statuses, AgentJido.ContentGen.default_statuses()) |> List.wrap() |> MapSet.new()
    explicit_entry = Map.get(opts, :entry)

    entries
    |> Enum.filter(&pages_collection?/1)
    |> Enum.filter(&destination_route?/1)
    |> Enum.filter(&section_match?(&1, section_filters))
    |> Enum.filter(&status_match?(&1, status_filters))
    |> Enum.filter(&entry_match?(&1, explicit_entry))
    |> Enum.sort_by(&{&1.section, &1.order, &1.id})
    |> limit(max_entries)
  end

  defp pages_collection?(entry), do: entry.destination_collection == :pages

  defp destination_route?(entry), do: is_binary(entry.destination_route) and entry.destination_route != ""

  defp section_match?(_entry, filters) when is_struct(filters, MapSet) and map_size(filters.map) == 0, do: true
  defp section_match?(entry, filters), do: MapSet.member?(filters, entry.section)

  defp status_match?(_entry, filters) when is_struct(filters, MapSet) and map_size(filters.map) == 0, do: true
  defp status_match?(entry, filters), do: MapSet.member?(filters, entry.status)

  defp entry_match?(_entry, nil), do: true
  defp entry_match?(entry, explicit_entry), do: entry.id == explicit_entry

  defp limit(entries, max_entries) when is_integer(max_entries) and max_entries > 0,
    do: Enum.take(entries, max_entries)

  defp limit(entries, _max_entries), do: entries
end
