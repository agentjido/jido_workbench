defmodule AgentJido.ContentGen.Backends.Backend do
  @moduledoc """
  Backend behavior for content generation providers.
  """

  @callback generate(String.t(), keyword()) ::
              {:ok, %{text: String.t(), meta: map()}} | {:error, term()}
end
