defmodule AgentJidoWeb.Icon do
  @moduledoc """
  Minimal icon helper for rendering Heroicon class names with optional mini variants.
  """

  use Phoenix.Component

  attr :name, :string, required: true
  attr :class, :any, default: nil
  attr :mini, :boolean, default: false
  attr :rest, :global

  def icon(assigns) do
    name =
      if assigns.mini and not String.ends_with?(assigns.name, "-mini"),
        do: assigns.name <> "-mini",
        else: assigns.name

    assigns = assign(assigns, :computed_name, name)

    ~H"""
    <span class={[@computed_name, @class]} {@rest} />
    """
  end
end
