defmodule AgentJido.ContentGen.Backends.ReqLLMBackend do
  @moduledoc """
  ReqLLM-backed generation using direct provider APIs.
  """

  @behaviour AgentJido.ContentGen.Backends.Backend

  alias ReqLLM.Context
  alias ReqLLM.Generation
  alias ReqLLM.Response

  @default_model "google:gemini-2.5-pro"

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    model = Keyword.get(opts, :model, @default_model)

    messages = [
      Context.system("You are an expert technical documentation author. Return only JSON."),
      Context.user(prompt)
    ]

    generation_opts =
      [temperature: 0.2, max_tokens: 8_000]
      |> maybe_put_opts(Keyword.get(opts, :generation_opts, []))

    case Generation.generate_text(model, messages, generation_opts) do
      {:ok, response} ->
        {:ok,
         %{
           text: Response.text(response) || "",
           meta: %{
             backend: :req_llm,
             model: model,
             usage: Response.usage(response)
           }
         }}

      {:error, error} ->
        {:error, Exception.message(error)}
    end
  end

  defp maybe_put_opts(base, extra) when is_list(extra), do: Keyword.merge(base, extra)
  defp maybe_put_opts(base, _extra), do: base
end
