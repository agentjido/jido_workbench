defmodule AgentJido.ArcanaTestEmbedder do
  @moduledoc false
  @behaviour Arcana.Embedder

  @dimensions 1536

  @impl true
  def embed(text, _opts) when is_binary(text) do
    vector =
      text
      |> String.downcase()
      |> :binary.bin_to_list()
      |> Enum.with_index()
      |> Enum.reduce(List.duplicate(0.0, @dimensions), fn {byte, idx}, acc ->
        position = rem(byte + idx, @dimensions)
        List.update_at(acc, position, &(&1 + 1.0))
      end)
      |> normalize()

    {:ok, vector}
  end

  @impl true
  def embed_batch(texts, opts) do
    embeddings = Enum.map(texts, fn text -> embed(text, opts) end)

    if Enum.all?(embeddings, &match?({:ok, _}, &1)) do
      {:ok, Enum.map(embeddings, fn {:ok, value} -> value end)}
    else
      {:error, :embedding_failed}
    end
  end

  @impl true
  def dimensions(_opts), do: @dimensions

  defp normalize(vector) do
    magnitude =
      vector
      |> Enum.reduce(0.0, fn value, acc -> acc + value * value end)
      |> :math.sqrt()

    if magnitude == 0.0 do
      vector
    else
      Enum.map(vector, &(&1 / magnitude))
    end
  end
end
