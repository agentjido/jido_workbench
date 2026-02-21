defmodule AgentJido.ContentGen.Backends.ReqLLMBackend do
  @moduledoc """
  ReqLLM-backed generation using direct provider APIs.
  """

  @behaviour AgentJido.ContentGen.Backends.Backend

  alias ReqLLM.Context
  alias ReqLLM.Generation
  alias ReqLLM.Response

  @default_model "google:gemini-2.5-pro"
  @default_max_tokens 8_000
  @default_receive_timeout_ms 180_000
  @output_schema [
    frontmatter: [type: :map, required: true, doc: "Frontmatter map for the page"],
    body_markdown: [type: :string, required: true, doc: "Markdown body without frontmatter fences"],
    citations: [type: {:list, :string}, required: false, doc: "Module or file references used"],
    audit_notes: [type: {:list, :string}, required: false, doc: "Generation notes for downstream auditing"]
  ]

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    model = Keyword.get(opts, :model, @default_model)

    messages = [
      Context.system("You are an expert technical documentation author. Return only JSON."),
      Context.user(prompt)
    ]

    generation_opts =
      [
        temperature: 0.2,
        max_tokens: @default_max_tokens,
        receive_timeout: @default_receive_timeout_ms,
        req_http_options: [receive_timeout: @default_receive_timeout_ms]
      ]
      |> maybe_put_opts(Keyword.get(opts, :generation_opts, []))

    case Generation.generate_object(model, messages, @output_schema, generation_opts) do
      {:ok, response} ->
        case Response.object(response) do
          object when is_map(object) and map_size(object) > 0 ->
            envelope = normalize_object_envelope(object)

            {:ok,
             %{
               text: Jason.encode!(envelope),
               meta: %{
                 backend: :req_llm,
                 mode: :structured_object,
                 model: model,
                 usage: Response.usage(response)
               }
             }}

          _missing_object ->
            generate_text_fallback(model, messages, generation_opts, :empty_structured_object_payload)
        end

      {:error, error} ->
        generate_text_fallback(model, messages, generation_opts, error)
    end
  end

  defp maybe_put_opts(base, extra) when is_list(extra), do: Keyword.merge(base, extra)
  defp maybe_put_opts(base, _extra), do: base

  defp generate_text_fallback(model, messages, generation_opts, object_error) do
    case Generation.generate_text(model, messages, generation_opts) do
      {:ok, response} ->
        {:ok,
         %{
           text: Response.text(response) || "",
           meta: %{
             backend: :req_llm,
             mode: :text_fallback,
             model: model,
             usage: Response.usage(response),
             object_error: normalize_error(object_error)
           }
         }}

      {:error, text_error} ->
        {:error, "object mode failed: #{normalize_error(object_error)}; text fallback failed: #{normalize_error(text_error)}"}
    end
  end

  defp normalize_object_envelope(payload) when is_map(payload) do
    %{
      frontmatter: payload[:frontmatter] || payload["frontmatter"] || %{},
      body_markdown: to_string(payload[:body_markdown] || payload["body_markdown"] || ""),
      citations: normalize_list(payload[:citations] || payload["citations"] || []),
      audit_notes: normalize_list(payload[:audit_notes] || payload["audit_notes"] || [])
    }
  end

  defp normalize_object_envelope(_other) do
    %{frontmatter: %{}, body_markdown: "", citations: [], audit_notes: []}
  end

  defp normalize_list(items) when is_list(items), do: Enum.map(items, &to_string/1)
  defp normalize_list(_other), do: []

  defp normalize_error(%{__exception__: true} = error), do: Exception.message(error)
  defp normalize_error(error) when is_atom(error), do: Atom.to_string(error)
  defp normalize_error(error) when is_binary(error), do: error
  defp normalize_error(error), do: inspect(error)
end
