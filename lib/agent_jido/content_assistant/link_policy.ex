defmodule AgentJido.ContentAssistant.LinkPolicy do
  @moduledoc """
  Applies post-render link policies to assistant answer HTML.

  This rollout enforces a strict citation-only policy.
  """

  alias AgentJido.ContentAssistant.Result
  alias AgentJido.ContentAssistant.URL

  @type policy :: :citation_only

  @spec apply(String.t(), [Result.t()], keyword()) :: String.t()
  def apply(answer_html, citations, opts \\ [])

  def apply(answer_html, citations, opts) when is_binary(answer_html) and is_list(citations) do
    case policy(opts) do
      :citation_only ->
        enforce_citation_only(answer_html, citations, opts)
    end
  end

  def apply(_answer_html, _citations, _opts), do: ""

  @spec citation_allowlist([Result.t()]) :: %{optional(String.t()) => non_neg_integer()}
  def citation_allowlist(citations) when is_list(citations) do
    citations
    |> Enum.with_index(1)
    |> Enum.reduce(%{}, fn
      {%Result{url: url}, rank}, acc ->
        case URL.normalize_href(url) do
          nil -> acc
          normalized -> Map.put_new(acc, normalized, rank)
        end

      _, acc ->
        acc
    end)
  end

  def citation_allowlist(_citations), do: %{}

  defp enforce_citation_only(answer_html, citations, opts) do
    allowlist = citation_allowlist(citations)
    channel = normalize_channel(Keyword.get(opts, :channel))
    source = normalize_source(Keyword.get(opts, :source, "content_assistant"))

    case Floki.parse_fragment(answer_html) do
      {:ok, nodes} ->
        nodes
        |> Enum.flat_map(&rewrite_node(&1, allowlist, source, channel))
        |> Floki.raw_html()

      _ ->
        ""
    end
  end

  defp rewrite_node({tag, attrs, children}, allowlist, source, channel) when is_binary(tag) do
    rewritten_children =
      children
      |> Enum.flat_map(&rewrite_node(&1, allowlist, source, channel))

    if tag == "a" do
      href =
        attrs
        |> List.keyfind("href", 0, {"href", nil})
        |> elem(1)
        |> URL.normalize_href()

      case href && Map.fetch(allowlist, href) do
        {:ok, rank} ->
          analytics_attrs = [
            {"data-analytics-event", "content_assistant_answer_link_clicked"},
            {"data-analytics-source", source},
            {"data-analytics-channel", channel},
            {"data-analytics-target-url", href},
            {"data-analytics-rank", Integer.to_string(rank)}
          ]

          safe_attrs =
            attrs
            |> upsert_attr("href", href)
            |> drop_attr("target")
            |> drop_attr("rel")
            |> merge_attrs(analytics_attrs)

          [{"a", safe_attrs, rewritten_children}]

        _ ->
          rewritten_children
      end
    else
      [{tag, attrs, rewritten_children}]
    end
  end

  defp rewrite_node(text, _allowlist, _source, _channel), do: [text]

  defp upsert_attr(attrs, key, value) when is_list(attrs) and is_binary(key) and is_binary(value) do
    attrs
    |> List.keystore(key, 0, {key, value})
  end

  defp drop_attr(attrs, key) when is_list(attrs) and is_binary(key) do
    Enum.reject(attrs, fn {attr_key, _value} -> attr_key == key end)
  end

  defp merge_attrs(attrs, new_attrs) when is_list(attrs) and is_list(new_attrs) do
    Enum.reduce(new_attrs, attrs, fn {key, value}, acc ->
      List.keystore(acc, key, 0, {key, value})
    end)
  end

  defp policy(opts) when is_list(opts) do
    case Keyword.get(opts, :policy, config_value(:answer_link_policy, :citation_only)) do
      :citation_only -> :citation_only
      _ -> :citation_only
    end
  end

  defp policy(_opts), do: :citation_only

  defp normalize_channel(channel) when is_binary(channel) and channel != "", do: channel
  defp normalize_channel(_channel), do: "content_assistant"

  defp normalize_source(source) when is_binary(source) and source != "", do: source
  defp normalize_source(_source), do: "content_assistant"

  defp config_value(key, default) do
    config = Application.get_env(:agent_jido, AgentJido.ContentAssistant, [])

    case config do
      cfg when is_list(cfg) -> Keyword.get(cfg, key, default)
      cfg when is_map(cfg) -> Map.get(cfg, key, default)
      _ -> default
    end
  end
end
