defmodule AgentJido.OGImage.Templates do
  @moduledoc """
  SVG template variants for Open Graph image rendering.
  """

  alias AgentJido.OGImage.Descriptor

  @image_width 1200
  @image_height 630

  @spec render_svg(Descriptor.t()) :: String.t()
  def render_svg(%Descriptor{template: :home} = descriptor), do: home_svg(descriptor)
  def render_svg(%Descriptor{template: :marketing} = descriptor), do: marketing_svg(descriptor)
  def render_svg(%Descriptor{template: :docs_page} = descriptor), do: docs_page_svg(descriptor)
  def render_svg(%Descriptor{template: :blog_post} = descriptor), do: blog_post_svg(descriptor)
  def render_svg(%Descriptor{template: :example} = descriptor), do: example_svg(descriptor)
  def render_svg(%Descriptor{template: :ecosystem_package} = descriptor), do: ecosystem_package_svg(descriptor)
  def render_svg(%Descriptor{template: :not_found} = descriptor), do: not_found_svg(descriptor)
  def render_svg(%Descriptor{} = descriptor), do: marketing_svg(descriptor)

  defp home_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <text x="600" y="165" font-family="system-ui, -apple-system, sans-serif" font-size="20" fill="#22d3ee" text-anchor="middle" letter-spacing="4">
        #{escape_text(descriptor.eyebrow || "JIDO")}
      </text>
      <text x="600" y="250" font-family="system-ui, -apple-system, sans-serif" font-size="66" font-weight="700" fill="#10b981" text-anchor="middle" filter="url(#glow)">
        #{escape_text(truncate(descriptor.title, 48))}
      </text>
      <text x="600" y="322" font-family="system-ui, -apple-system, sans-serif" font-size="30" fill="#f8fafc" text-anchor="middle">
        #{escape_text(truncate(descriptor.subtitle || "", 74))}
      </text>
      #{badges_svg(descriptor.badges || ["Elixir/OTP", "Multi-Agent", "Production"], 412)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp marketing_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <text x="90" y="110" font-family="system-ui, -apple-system, sans-serif" font-size="20" fill="#22d3ee" letter-spacing="4">
        #{escape_text(descriptor.eyebrow || "JIDO")}
      </text>
      <text x="90" y="250" font-family="system-ui, -apple-system, sans-serif" font-size="66" font-weight="700" fill="#10b981">
        #{escape_text(truncate(descriptor.title, 34))}
      </text>
      <text x="90" y="320" font-family="system-ui, -apple-system, sans-serif" font-size="30" fill="#f8fafc">
        #{escape_text(truncate(descriptor.subtitle || "", 70))}
      </text>
      #{badges_svg(descriptor.badges || [], 406, 90)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp docs_page_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <rect x="90" y="92" width="154" height="36" rx="18" fill="#22d3ee" fill-opacity="0.18" />
      <text x="167" y="116" font-family="system-ui, -apple-system, sans-serif" font-size="17" fill="#22d3ee" text-anchor="middle">
        #{escape_text(descriptor.eyebrow || "DOCS")}
      </text>
      <text x="90" y="250" font-family="system-ui, -apple-system, sans-serif" font-size="58" font-weight="700" fill="#f8fafc">
        #{escape_text(truncate(descriptor.title, 40))}
      </text>
      <text x="90" y="320" font-family="system-ui, -apple-system, sans-serif" font-size="28" fill="#cbd5e1">
        #{escape_text(truncate(descriptor.subtitle || "", 78))}
      </text>
      #{badges_svg(descriptor.badges || ["Reference"], 406, 90)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp blog_post_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <rect x="90" y="90" width="190" height="36" rx="18" fill="#10b981" fill-opacity="0.2" />
      <text x="185" y="114" font-family="system-ui, -apple-system, sans-serif" font-size="17" fill="#34d399" text-anchor="middle">
        #{escape_text(descriptor.eyebrow || "BLOG POST")}
      </text>
      <text x="90" y="238" font-family="system-ui, -apple-system, sans-serif" font-size="54" font-weight="700" fill="#f8fafc">
        #{escape_text(truncate(descriptor.title, 42))}
      </text>
      <text x="90" y="306" font-family="system-ui, -apple-system, sans-serif" font-size="27" fill="#cbd5e1">
        #{escape_text(truncate(descriptor.subtitle || "", 86))}
      </text>
      #{badges_svg(descriptor.badges || [], 390, 90)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp example_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <rect x="90" y="90" width="170" height="36" rx="18" fill="#0ea5e9" fill-opacity="0.2" />
      <text x="175" y="114" font-family="system-ui, -apple-system, sans-serif" font-size="17" fill="#38bdf8" text-anchor="middle">
        #{escape_text(descriptor.eyebrow || "EXAMPLE")}
      </text>
      <text x="90" y="238" font-family="system-ui, -apple-system, sans-serif" font-size="56" font-weight="700" fill="#f8fafc">
        #{escape_text(truncate(descriptor.title, 42))}
      </text>
      <text x="90" y="306" font-family="system-ui, -apple-system, sans-serif" font-size="27" fill="#cbd5e1">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 390, 90)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp ecosystem_package_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      <rect x="90" y="90" width="230" height="36" rx="18" fill="#f59e0b" fill-opacity="0.2" />
      <text x="205" y="114" font-family="system-ui, -apple-system, sans-serif" font-size="17" fill="#fbbf24" text-anchor="middle">
        #{escape_text(descriptor.eyebrow || "ECOSYSTEM PACKAGE")}
      </text>
      <text x="90" y="238" font-family="system-ui, -apple-system, sans-serif" font-size="54" font-weight="700" fill="#f8fafc">
        #{escape_text(truncate(descriptor.title, 38))}
      </text>
      <text x="90" y="306" font-family="system-ui, -apple-system, sans-serif" font-size="27" fill="#cbd5e1">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 390, 90)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp not_found_svg(descriptor) do
    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{frame()}
      <text x="600" y="240" font-family="system-ui, -apple-system, sans-serif" font-size="56" font-weight="700" fill="#f8fafc" text-anchor="middle">
        #{escape_text(truncate(descriptor.title, 40))}
      </text>
      <text x="600" y="308" font-family="system-ui, -apple-system, sans-serif" font-size="28" fill="#cbd5e1" text-anchor="middle">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 390)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp background_gradient do
    """
    <linearGradient id="bggrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0f172a"/>
      <stop offset="55%" stop-color="#111827"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
    """
  end

  defp glow_filter do
    """
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur" />
      <feMerge>
        <feMergeNode in="blur" />
        <feMergeNode in="SourceGraphic" />
      </feMerge>
    </filter>
    """
  end

  defp decorative_shapes do
    """
    <circle cx="98" cy="96" r="180" fill="#10b981" fill-opacity="0.06" />
    <circle cx="1120" cy="558" r="240" fill="#22d3ee" fill-opacity="0.06" />
    <circle cx="920" cy="70" r="110" fill="#0ea5e9" fill-opacity="0.05" />
    """
  end

  defp frame do
    """
    <rect x="20" y="20" width="#{@image_width - 40}" height="#{@image_height - 40}" rx="16" ry="16" fill="none" stroke="#10b981" stroke-opacity="0.22" stroke-width="1" />
    """
  end

  defp badges_svg(labels, y, start_x \\ nil)
  defp badges_svg([], _y, _start_x), do: ""

  defp badges_svg(labels, y, start_x) do
    labels = labels |> Enum.map(&to_string/1) |> Enum.uniq() |> Enum.take(5)
    widths = Enum.map(labels, fn label -> 44 + String.length(label) * 9 end)
    spacing = 12
    total_width = Enum.sum(widths) + max(length(widths) - 1, 0) * spacing
    initial_x = start_x || round((@image_width - total_width) / 2)

    {svg, _next_x} =
      Enum.zip(labels, widths)
      |> Enum.reduce({"", initial_x}, fn {label, width}, {acc, x} ->
        fragment = """
        <rect x="#{x}" y="#{y}" width="#{width}" height="38" rx="19" fill="#22d3ee" fill-opacity="0.12" stroke="#22d3ee" stroke-opacity="0.38" stroke-width="1" />
        <text x="#{x + width / 2}" y="#{y + 24}" font-family="system-ui, -apple-system, sans-serif" font-size="15" fill="#99f6e4" text-anchor="middle">
          #{escape_text(label)}
        </text>
        """

        {acc <> fragment, x + width + spacing}
      end)

    svg
  end

  defp footer_line(url) do
    """
    <line x1="150" y1="542" x2="1050" y2="542" stroke="#10b981" stroke-opacity="0.22" stroke-width="1" />
    <text x="600" y="586" font-family="system-ui, -apple-system, sans-serif" font-size="20" fill="#99f6e4" fill-opacity="0.85" text-anchor="middle">
      #{escape_text(truncate(url, 66))}
    </text>
    """
  end

  defp truncate(nil, _max_length), do: ""

  defp truncate(text, max_length) when is_binary(text) do
    if String.length(text) > max_length do
      String.slice(text, 0, max_length - 1) <> "..."
    else
      text
    end
  end

  defp truncate(text, max_length), do: truncate(to_string(text), max_length)

  defp escape_text(nil), do: ""

  defp escape_text(text) when is_binary(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp escape_text(text), do: escape_text(to_string(text))
end
