defmodule AgentJido.ContentOps.Chat.ContentResolver do
  @moduledoc """
  Deterministically resolves documentation/content targets for doc-note workflows.
  """

  alias AgentJido.{ContentPlan, Pages}

  @fuzzy_threshold 0.70
  @winner_margin 0.08
  @max_candidates 3

  @type target :: %{
          type: :page | :content_plan,
          id: String.t(),
          title: String.t(),
          path: String.t() | nil,
          slug: String.t() | nil
        }

  @type result :: {:ok, target()} | {:ambiguous, [map()]} | {:error, :not_found | :missing_ref}

  @doc """
  Resolve a content target from a user-provided page reference.
  """
  @spec resolve(String.t() | nil) :: result()
  def resolve(page_ref) do
    resolve(page_ref, pages: Pages.all_pages(), entries: ContentPlan.all_entries())
  end

  @doc false
  @spec resolve(String.t() | nil, keyword()) :: result()
  def resolve(page_ref, opts) do
    query =
      page_ref
      |> normalize_ref()

    if query == "" do
      {:error, :missing_ref}
    else
      pages = Keyword.get(opts, :pages, [])
      entries = Keyword.get(opts, :entries, [])
      candidates = build_candidates(pages, entries)

      case exact_matches(query, candidates) do
        [one] ->
          {:ok, strip_score(one)}

        many when length(many) > 1 ->
          {:ambiguous, format_ambiguous(many)}

        [] ->
          fuzzy_resolve(query, candidates)
      end
    end
  end

  defp fuzzy_resolve(query, candidates) do
    ranked =
      candidates
      |> Enum.map(fn candidate ->
        score = fuzzy_score(query, candidate)
        Map.put(candidate, :score, score)
      end)
      |> Enum.filter(&(&1.score >= @fuzzy_threshold))
      |> Enum.sort_by(& &1.score, :desc)

    case ranked do
      [] ->
        {:error, :not_found}

      [one] ->
        {:ok, strip_score(one)}

      [top, second | _] ->
        if top.score - second.score >= @winner_margin do
          {:ok, strip_score(top)}
        else
          {:ambiguous, format_ambiguous(ranked)}
        end
    end
  end

  defp exact_matches(query, candidates) do
    Enum.filter(candidates, fn candidate ->
      candidate
      |> exact_fields()
      |> Enum.any?(&(normalize_ref(&1) == query))
    end)
  end

  defp exact_fields(candidate) do
    [
      candidate.id,
      candidate.slug,
      candidate.path,
      path_without_leading_slash(candidate.path)
    ]
    |> Enum.reject(&is_nil/1)
  end

  defp fuzzy_score(query, candidate) do
    fields =
      [
        candidate.id,
        candidate.slug,
        candidate.title,
        candidate.path,
        path_without_leading_slash(candidate.path)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&normalize_ref/1)

    Enum.reduce(fields, 0.0, fn field, acc ->
      score =
        cond do
          field == "" ->
            0.0

          String.contains?(field, query) ->
            0.95

          true ->
            String.jaro_distance(query, field)
        end

      max(acc, score)
    end)
  end

  defp format_ambiguous(candidates) do
    candidates
    |> Enum.take(@max_candidates)
    |> Enum.map(fn candidate ->
      %{
        type: candidate.type,
        id: candidate.id,
        title: candidate.title,
        path: candidate.path,
        slug: candidate.slug,
        score: Float.round(candidate.score || 1.0, 4)
      }
    end)
  end

  defp strip_score(candidate) do
    Map.drop(candidate, [:score])
  end

  defp normalize_ref(nil), do: ""

  defp normalize_ref(ref) when is_binary(ref) do
    ref
    |> String.trim()
    |> extract_path_if_url()
    |> String.trim()
    |> String.downcase()
  end

  defp normalize_ref(ref), do: ref |> to_string() |> normalize_ref()

  defp extract_path_if_url(ref) do
    case URI.parse(ref) do
      %URI{scheme: nil} ->
        ref

      %URI{path: nil} ->
        ref

      %URI{path: path} ->
        path
    end
  rescue
    _ ->
      ref
  end

  defp path_without_leading_slash(nil), do: nil
  defp path_without_leading_slash(path), do: String.trim_leading(path, "/")

  defp build_candidates(pages, entries) do
    page_candidates =
      Enum.map(pages, fn page ->
        %{
          type: :page,
          id: page.id,
          title: page.title,
          path: page.path,
          slug: page.id
        }
      end)

    plan_candidates =
      Enum.map(entries, fn entry ->
        %{
          type: :content_plan,
          id: entry.id,
          title: entry.title,
          path: entry.destination_route,
          slug: entry.slug
        }
      end)

    page_candidates ++ plan_candidates
  end
end
