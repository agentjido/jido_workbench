defmodule AgentJidoWeb.ContentGenerator.Diff do
  @moduledoc """
  Builds a lightweight inline unified diff model for dashboard rendering.
  """

  @type line_kind :: :context | :add | :remove

  @spec unified(String.t() | nil, String.t() | nil, keyword()) :: map()
  def unified(old_text, new_text, opts \\ []) do
    max_lines = Keyword.get(opts, :max_lines, 600)

    old_lines = split_lines(old_text)
    new_lines = split_lines(new_text)

    {lines, counts} =
      old_lines
      |> List.myers_difference(new_lines)
      |> Enum.reduce({[], %{add: 0, remove: 0, context: 0}}, fn
        {:eq, chunk}, {line_acc, count_acc} ->
          {
            line_acc ++ Enum.map(chunk, &line(:context, &1)),
            %{count_acc | context: count_acc.context + length(chunk)}
          }

        {:ins, chunk}, {line_acc, count_acc} ->
          {
            line_acc ++ Enum.map(chunk, &line(:add, &1)),
            %{count_acc | add: count_acc.add + length(chunk)}
          }

        {:del, chunk}, {line_acc, count_acc} ->
          {
            line_acc ++ Enum.map(chunk, &line(:remove, &1)),
            %{count_acc | remove: count_acc.remove + length(chunk)}
          }
      end)

    {visible_lines, truncated?} =
      if length(lines) > max_lines do
        {Enum.take(lines, max_lines), true}
      else
        {lines, false}
      end

    %{
      lines: visible_lines,
      truncated?: truncated?,
      max_lines: max_lines,
      total_lines: length(lines),
      stats: %{
        added: counts.add,
        removed: counts.remove,
        context: counts.context,
        old_lines: length(old_lines),
        new_lines: length(new_lines),
        delta_lines: length(new_lines) - length(old_lines)
      }
    }
  end

  defp line(kind, text) do
    %{
      kind: kind,
      prefix: prefix(kind),
      text: text || ""
    }
  end

  defp prefix(:context), do: " "
  defp prefix(:add), do: "+"
  defp prefix(:remove), do: "-"

  defp split_lines(nil), do: []

  defp split_lines(text) when is_binary(text) do
    text
    |> String.split("\n", trim: false)
    |> trim_terminal_empty()
  end

  defp split_lines(_text), do: []

  defp trim_terminal_empty([]), do: []

  defp trim_terminal_empty(lines) do
    if List.last(lines) == "" do
      Enum.drop(lines, -1)
    else
      lines
    end
  end
end
