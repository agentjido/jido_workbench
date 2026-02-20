defmodule AgentJido.OGImage.Templates do
  @moduledoc """
  SVG template variants for Open Graph image rendering.
  """

  alias AgentJido.OGImage.Descriptor

  @image_width 1200
  @image_height 630

  # Dark-mode aligned palette (matches site tokens more closely than the old blue-heavy gradient)
  @color_bg_start "#0a0a0a"
  @color_bg_mid "#0d0f12"
  @color_bg_end "#15191f"
  @color_surface "#17191e"
  @color_border "#2a2d32"

  @color_text "#e8e8e8"
  @color_text_muted "#9aa0a8"

  @color_primary "#00ff88"
  @color_primary_soft "#6cf3be"
  @color_cyan "#00ccff"
  @color_yellow "#ffb700"

  @spec render_svg(Descriptor.t()) :: String.t()
  def render_svg(%Descriptor{template: :home} = descriptor), do: home_svg(descriptor)
  def render_svg(%Descriptor{template: :marketing} = descriptor), do: marketing_svg(descriptor)
  def render_svg(%Descriptor{template: :docs_page} = descriptor), do: docs_page_svg(descriptor)
  def render_svg(%Descriptor{template: :blog_post} = descriptor), do: blog_post_svg(descriptor)
  def render_svg(%Descriptor{template: :example} = descriptor), do: example_svg(descriptor)

  def render_svg(%Descriptor{template: :ecosystem_package} = descriptor),
    do: ecosystem_package_svg(descriptor)

  def render_svg(%Descriptor{template: :not_found} = descriptor), do: not_found_svg(descriptor)
  def render_svg(%Descriptor{} = descriptor), do: marketing_svg(descriptor)

  defp home_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 46, 34)
    subtitle_size = subtitle_font_size(descriptor.subtitle, 22, 18)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "JIDO", 600, 110, @color_cyan, "middle")}
      <text x="600" y="214" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_primary_soft}" text-anchor="middle">
        #{escape_text(truncate(descriptor.title, 40))}
      </text>
      <text x="600" y="260" font-family="system-ui, -apple-system, sans-serif" font-size="#{subtitle_size}" fill="#{@color_text}" text-anchor="middle">
        #{escape_text(truncate(descriptor.subtitle || "", 74))}
      </text>
      #{badges_svg(descriptor.badges || ["Elixir/OTP", "Multi-Agent", "Production"], 318, accent: @color_cyan)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp marketing_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 44, 32)
    subtitle_size = subtitle_font_size(descriptor.subtitle, 20, 16)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "JIDO", 90, 110, @color_cyan)}
      <text x="90" y="206" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_text}">
        #{escape_text(truncate(descriptor.title, 38))}
      </text>
      <text x="90" y="248" font-family="system-ui, -apple-system, sans-serif" font-size="#{subtitle_size}" fill="#{@color_text_muted}">
        #{escape_text(truncate(descriptor.subtitle || "", 78))}
      </text>
      #{badges_svg(descriptor.badges || [], 304, start_x: 90, accent: @color_primary)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp docs_page_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 42, 32)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "DOCS", 90, 110, @color_cyan)}
      <text x="90" y="202" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_text}">
        #{escape_text(truncate(descriptor.title, 42))}
      </text>
      <text x="90" y="244" font-family="system-ui, -apple-system, sans-serif" font-size="18" fill="#{@color_text_muted}">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || ["Reference"], 304, start_x: 90, accent: @color_cyan)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp blog_post_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 42, 32)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "BLOG POST", 90, 110, @color_primary)}
      <text x="90" y="202" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_text}">
        #{escape_text(truncate(descriptor.title, 42))}
      </text>
      <text x="90" y="244" font-family="system-ui, -apple-system, sans-serif" font-size="18" fill="#{@color_text_muted}">
        #{escape_text(truncate(descriptor.subtitle || "", 84))}
      </text>
      #{badges_svg(descriptor.badges || [], 304, start_x: 90, accent: @color_primary)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp example_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 42, 32)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "EXAMPLE", 90, 110, @color_yellow)}
      <text x="90" y="202" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_text}">
        #{escape_text(truncate(descriptor.title, 42))}
      </text>
      <text x="90" y="244" font-family="system-ui, -apple-system, sans-serif" font-size="18" fill="#{@color_text_muted}">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 304, start_x: 90, accent: @color_yellow)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp ecosystem_package_svg(descriptor) do
    title_size = title_font_size(descriptor.title, 42, 32)

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_shapes()}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || "ECOSYSTEM PACKAGE", 90, 110, @color_yellow)}
      <text x="90" y="202" font-family="system-ui, -apple-system, sans-serif" font-size="#{title_size}" font-weight="700" fill="#{@color_text}">
        #{escape_text(truncate(descriptor.title, 40))}
      </text>
      <text x="90" y="244" font-family="system-ui, -apple-system, sans-serif" font-size="18" fill="#{@color_text_muted}">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 304, start_x: 90, accent: @color_yellow)}
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
      #{eyebrow_text(descriptor.eyebrow || "NOT FOUND", 600, 120, @color_cyan, "middle")}
      <text x="600" y="228" font-family="system-ui, -apple-system, sans-serif" font-size="42" font-weight="700" fill="#{@color_text}" text-anchor="middle">
        #{escape_text(truncate(descriptor.title, 40))}
      </text>
      <text x="600" y="272" font-family="system-ui, -apple-system, sans-serif" font-size="18" fill="#{@color_text_muted}" text-anchor="middle">
        #{escape_text(truncate(descriptor.subtitle || "", 82))}
      </text>
      #{badges_svg(descriptor.badges || [], 320, accent: @color_cyan)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp background_gradient do
    """
    <linearGradient id="bggrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#{@color_bg_start}"/>
      <stop offset="52%" stop-color="#{@color_bg_mid}"/>
      <stop offset="100%" stop-color="#{@color_bg_end}"/>
    </linearGradient>
    """
  end

  defp decorative_shapes do
    ""
  end

  defp frame do
    """
    <rect x="16" y="16" width="#{@image_width - 32}" height="#{@image_height - 32}" rx="14" ry="14" fill="none" stroke="#{@color_border}" stroke-width="1" />
    """
  end

  defp eyebrow_text(text, x, y, accent, anchor \\ "start") do
    """
    <text x="#{x}" y="#{y}" font-family="system-ui, -apple-system, sans-serif" font-size="14" fill="#{accent}" text-anchor="#{anchor}" letter-spacing="2.2">
      #{escape_text(text)}
    </text>
    """
  end

  defp badges_svg([], _y, _opts), do: ""

  defp badges_svg(labels, y, opts) do
    labels = labels |> Enum.map(&to_string/1) |> Enum.uniq() |> Enum.take(3)
    widths = Enum.map(labels, fn label -> 30 + String.length(label) * 7 end)
    spacing = 8
    total_width = Enum.sum(widths) + max(length(widths) - 1, 0) * spacing

    initial_x =
      case Keyword.get(opts, :start_x) do
        nil -> round((@image_width - total_width) / 2)
        value -> value
      end

    accent = Keyword.get(opts, :accent, @color_cyan)

    {svg, _next_x} =
      Enum.zip(labels, widths)
      |> Enum.reduce({"", initial_x}, fn {label, width}, {acc, x} ->
        fragment = """
        <rect x="#{x}" y="#{y}" width="#{width}" height="28" rx="14" fill="#{@color_surface}" fill-opacity="0.72" stroke="#{accent}" stroke-opacity="0.28" stroke-width="1" />
        <text x="#{x + width / 2}" y="#{y + 19}" font-family="system-ui, -apple-system, sans-serif" font-size="12" fill="#{accent}" text-anchor="middle">
          #{escape_text(label)}
        </text>
        """

        {acc <> fragment, x + width + spacing}
      end)

    svg
  end

  defp footer_line(url) do
    """
    <line x1="90" y1="540" x2="1110" y2="540" stroke="#{@color_border}" stroke-width="1" />
    <text x="600" y="578" font-family="system-ui, -apple-system, sans-serif" font-size="16" fill="#{@color_text_muted}" text-anchor="middle">
      #{escape_text(truncate(url, 66))}
    </text>
    """
  end

  defp title_font_size(nil, base, _min), do: base

  defp title_font_size(text, base, min) when is_binary(text) do
    len = String.length(text)

    cond do
      len <= 20 -> base
      len <= 30 -> max(base - 4, min)
      len <= 40 -> max(base - 8, min)
      len <= 52 -> max(base - 12, min)
      true -> min
    end
  end

  defp title_font_size(text, base, min), do: title_font_size(to_string(text), base, min)

  defp subtitle_font_size(nil, base, _min), do: base

  defp subtitle_font_size(text, base, min) when is_binary(text) do
    len = String.length(text)

    cond do
      len <= 56 -> base
      len <= 74 -> max(base - 2, min)
      len <= 92 -> max(base - 4, min)
      true -> min
    end
  end

  defp subtitle_font_size(text, base, min), do: subtitle_font_size(to_string(text), base, min)

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
