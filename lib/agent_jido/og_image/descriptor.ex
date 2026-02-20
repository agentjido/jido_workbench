defmodule AgentJido.OGImage.Descriptor do
  @moduledoc """
  Normalized route/content descriptor used to render Open Graph images.
  """

  @type template ::
          :home
          | :marketing
          | :docs_page
          | :blog_post
          | :example
          | :ecosystem_package
          | :not_found

  @enforce_keys [:template, :title, :footer_url, :content_hash, :cache_key, :resolved_path]
  defstruct [
    :template,
    :title,
    :subtitle,
    :eyebrow,
    :footer_url,
    :badges,
    :content_hash,
    :cache_key,
    :resolved_path
  ]

  @type t :: %__MODULE__{
          template: template(),
          title: String.t(),
          subtitle: String.t() | nil,
          eyebrow: String.t() | nil,
          footer_url: String.t(),
          badges: [String.t()],
          content_hash: String.t(),
          cache_key: String.t(),
          resolved_path: String.t()
        }
end
