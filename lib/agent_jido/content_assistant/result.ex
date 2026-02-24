defmodule AgentJido.ContentAssistant.Result do
  @moduledoc """
  Normalized citation result used by the content assistant.
  """

  @enforce_keys [:title, :snippet, :url, :source_type]
  defstruct [:title, :snippet, :url, :source_type, :score]

  @type source_type :: :docs | :blog | :ecosystem

  @type t :: %__MODULE__{
          title: String.t(),
          snippet: String.t(),
          url: String.t(),
          source_type: source_type(),
          score: number() | nil
        }
end
