defmodule AgentJido.OGImage.Templates do
  @moduledoc """
  SVG template variants for Open Graph image rendering.
  """

  alias AgentJido.OGImage.Descriptor

  @image_width 1200
  @image_height 630

  # Dark-mode aligned palette (derived from homepage tokens).
  @color_bg_start "#0a0a0a"
  @color_bg_mid "#0c0f12"
  @color_bg_end "#121820"
  @color_surface "#14181d"
  @color_border "#292e36"
  @color_border_soft "#1b1f26"

  @color_text "#e8e8e8"
  @color_text_muted "#8f96a1"
  @color_text_subtle "#6f7783"

  @color_primary "#00ff88"
  @color_primary_soft "#6cf3be"
  @color_cyan "#00ccff"
  @color_yellow "#ffb700"
  @color_red "#e98181"

  @layout_content_x 90
  @layout_content_width 760
  @layout_eyebrow_y 112
  @layout_title_y 198
  @layout_footer_line_y 540
  @layout_footer_text_y 578

  @title_sizes [44, 40, 36, 32]
  @subtitle_sizes [21, 19, 17, 15]

  @title_line_height_factor 1.14
  @subtitle_line_height_factor 1.32

  @badge_font_size 12
  @badge_min_width 52
  @badge_max_width 220
  @badge_height 30
  @badge_pad_x 14
  @badge_spacing 10
  @max_badges 3

  @spec render_svg(Descriptor.t()) :: String.t()
  def render_svg(%Descriptor{} = descriptor), do: editorial_svg(descriptor)

  defp editorial_svg(descriptor) do
    theme = template_theme(descriptor.template)
    title_text = descriptor.title || ""
    subtitle_text = descriptor.subtitle || ""

    title_layout = layout_text(title_text, @title_sizes, @layout_content_width, 2)

    title_height =
      text_block_height(title_layout.font_size, title_layout.lines, @title_line_height_factor)

    subtitle_layout = layout_text(subtitle_text, @subtitle_sizes, @layout_content_width, 2)

    subtitle_y = @layout_title_y + title_height + 22

    subtitle_height =
      text_block_height(subtitle_layout.font_size, subtitle_layout.lines, @subtitle_line_height_factor)

    badges_y = subtitle_y + subtitle_height + 30

    """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{accent_gradient(theme.accent)}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)" />
      #{decorative_surfaces(theme.accent)}
      #{frame()}
      #{eyebrow_text(descriptor.eyebrow || theme.eyebrow, @layout_content_x, @layout_eyebrow_y, theme.accent)}
      #{text_block_svg(title_layout.lines,
    x: @layout_content_x,
    y: @layout_title_y,
    font_size: title_layout.font_size,
    font_weight: 700,
    fill: theme.title_fill,
    line_height_factor: @title_line_height_factor)}
      #{text_block_svg(subtitle_layout.lines,
    x: @layout_content_x,
    y: subtitle_y,
    font_size: subtitle_layout.font_size,
    font_weight: 500,
    fill: @color_text_muted,
    line_height_factor: @subtitle_line_height_factor)}
      #{badges_svg(descriptor.badges || [], badges_y, theme.badge_accent)}
      #{footer_line(descriptor.footer_url)}
    </svg>
    """
  end

  defp template_theme(:home) do
    %{
      eyebrow: "JIDO",
      accent: @color_primary,
      title_fill: @color_primary_soft,
      badge_accent: @color_primary
    }
  end

  defp template_theme(:marketing) do
    %{eyebrow: "JIDO", accent: @color_cyan, title_fill: @color_text, badge_accent: @color_primary}
  end

  defp template_theme(:docs_page) do
    %{eyebrow: "DOCS", accent: @color_cyan, title_fill: @color_text, badge_accent: @color_cyan}
  end

  defp template_theme(:blog_post) do
    %{
      eyebrow: "BLOG POST",
      accent: @color_primary,
      title_fill: @color_text,
      badge_accent: @color_primary
    }
  end

  defp template_theme(:example) do
    %{eyebrow: "EXAMPLE", accent: @color_yellow, title_fill: @color_text, badge_accent: @color_yellow}
  end

  defp template_theme(:ecosystem_package) do
    %{
      eyebrow: "ECOSYSTEM PACKAGE",
      accent: @color_yellow,
      title_fill: @color_text,
      badge_accent: @color_yellow
    }
  end

  defp template_theme(:not_found) do
    %{eyebrow: "NOT FOUND", accent: @color_red, title_fill: @color_text, badge_accent: @color_red}
  end

  defp template_theme(_template) do
    %{eyebrow: "JIDO", accent: @color_cyan, title_fill: @color_text, badge_accent: @color_primary}
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

  defp accent_gradient(accent) do
    """
    <linearGradient id="accentglow" x1="0" y1="0" x2="0.9" y2="1">
      <stop offset="0%" stop-color="#{accent}" stop-opacity="0.13"/>
      <stop offset="48%" stop-color="#{accent}" stop-opacity="0.06"/>
      <stop offset="100%" stop-color="#{accent}" stop-opacity="0"/>
    </linearGradient>
    """
  end

  defp decorative_surfaces(accent) do
    """
    <rect x="812" y="74" width="300" height="402" rx="18" fill="url(#accentglow)" />
    <line x1="812" y1="92" x2="1112" y2="92" stroke="#{accent}" stroke-opacity="0.12" stroke-width="1" />
    <circle cx="1050" cy="512" r="118" fill="#{accent}" fill-opacity="0.05" />
    <circle cx="978" cy="150" r="64" fill="#{accent}" fill-opacity="0.035" />
    """
  end

  defp frame do
    """
    <rect x="16" y="16" width="#{@image_width - 32}" height="#{@image_height - 32}" rx="14" ry="14" fill="none" stroke="#{@color_border}" stroke-width="1" />
    <rect x="18" y="18" width="#{@image_width - 36}" height="#{@image_height - 36}" rx="13" ry="13" fill="none" stroke="#{@color_border_soft}" stroke-width="1" />
    """
  end

  defp eyebrow_text(text, x, y, accent) do
    """
    <text x="#{x}" y="#{y}" font-family="system-ui, -apple-system, sans-serif" font-size="15" font-weight="600" fill="#{accent}" letter-spacing="2.1">
      #{escape_text(text)}
    </text>
    """
  end

  defp text_block_svg([], _opts), do: ""

  defp text_block_svg(lines, opts) do
    x = Keyword.fetch!(opts, :x)
    y = Keyword.fetch!(opts, :y)
    font_size = Keyword.fetch!(opts, :font_size)
    fill = Keyword.fetch!(opts, :fill)
    font_weight = Keyword.get(opts, :font_weight, 700)
    line_height_factor = Keyword.get(opts, :line_height_factor, 1.2)
    line_height = round(font_size * line_height_factor)

    [first_line | rest_lines] = lines

    rest_svg =
      Enum.map_join(rest_lines, "", fn line ->
        """
        <tspan x="#{x}" dy="#{line_height}">#{escape_text(line)}</tspan>
        """
      end)

    """
    <text x="#{x}" y="#{y}" font-family="system-ui, -apple-system, sans-serif" font-size="#{font_size}" font-weight="#{font_weight}" fill="#{fill}" text-anchor="start">
      <tspan x="#{x}" y="#{y}">#{escape_text(first_line)}</tspan>
      #{rest_svg}
    </text>
    """
  end

  defp badges_svg(labels, y, accent) do
    fitted_badges = fit_badges(labels, @layout_content_width, @max_badges)

    if fitted_badges == [] do
      ""
    else
      {svg, _next_x} =
        Enum.reduce(fitted_badges, {"", @layout_content_x}, fn label, {acc, x} ->
          width = badge_width(label)

          fragment = """
          <rect x="#{x}" y="#{y}" width="#{width}" height="#{@badge_height}" rx="15" fill="#{@color_surface}" fill-opacity="0.72" stroke="#{accent}" stroke-opacity="0.34" stroke-width="1" />
          <text x="#{x + width / 2}" y="#{y + 20}" font-family="system-ui, -apple-system, sans-serif" font-size="#{@badge_font_size}" font-weight="500" fill="#{accent}" text-anchor="middle">
            #{escape_text(label)}
          </text>
          """

          {acc <> fragment, x + width + @badge_spacing}
        end)

      svg
    end
  end

  defp fit_badges(labels, max_width, max_count) do
    labels =
      labels
      |> Enum.map(&normalize_text/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()

    {picked, _consumed_width} =
      Enum.reduce(labels, {[], 0}, fn label, {acc, consumed} ->
        fitted_label = fit_text_with_ellipsis(label, @badge_font_size, @badge_max_width - @badge_pad_x * 2)
        width = badge_width(fitted_label)
        next_consumed = if consumed == 0, do: width, else: consumed + @badge_spacing + width

        if length(acc) < max_count and next_consumed <= max_width do
          {acc ++ [fitted_label], next_consumed}
        else
          {acc, consumed}
        end
      end)

    case picked do
      [] ->
        case labels do
          [] -> []
          [first | _] -> [fit_text_with_ellipsis(first, @badge_font_size, max_width - @badge_pad_x * 2)]
        end

      _ ->
        picked
    end
  end

  defp badge_width(label) do
    label_width = round(estimate_line_width(label, @badge_font_size))

    label_width
    |> Kernel.+(@badge_pad_x * 2)
    |> max(@badge_min_width)
    |> min(@badge_max_width)
  end

  defp footer_line(url) do
    footer_label = fit_text_with_ellipsis(normalize_text(url), 16, 560)

    """
    <line x1="90" y1="#{@layout_footer_line_y}" x2="1110" y2="#{@layout_footer_line_y}" stroke="#{@color_border}" stroke-width="1" />
    <text x="600" y="#{@layout_footer_text_y}" font-family="system-ui, -apple-system, sans-serif" font-size="16" fill="#{@color_text_subtle}" text-anchor="middle">
      #{escape_text(footer_label)}
    </text>
    """
  end

  defp text_block_height(_font_size, [], _line_height_factor), do: 0

  defp text_block_height(font_size, lines, line_height_factor) do
    line_height = round(font_size * line_height_factor)
    font_size + max(length(lines) - 1, 0) * line_height
  end

  defp layout_text(text, font_sizes, max_width, max_lines) do
    value = normalize_text(text)

    if value == "" do
      %{font_size: List.last(font_sizes), lines: []}
    else
      case Enum.find_value(font_sizes, fn size ->
             {lines, overflow?} = wrap_text(value, size, max_width, max_lines, false)
             if overflow?, do: nil, else: %{font_size: size, lines: lines}
           end) do
        nil ->
          smallest = List.last(font_sizes)
          {lines, _overflow?} = wrap_text(value, smallest, max_width, max_lines, true)
          %{font_size: smallest, lines: lines}

        layout ->
          layout
      end
    end
  end

  defp wrap_text(text, font_size, max_width, max_lines, truncate_overflow?) do
    tokens = split_tokens_to_fit(text, font_size, max_width)
    {lines, remainder} = wrap_tokens(tokens, font_size, max_width, max_lines)
    overflow? = remainder != []

    wrapped_lines =
      if overflow? and truncate_overflow? do
        truncate_last_line(lines, font_size, max_width)
      else
        lines
      end

    {wrapped_lines, overflow?}
  end

  defp split_tokens_to_fit(text, font_size, max_width) do
    text
    |> normalize_text()
    |> String.split(" ", trim: true)
    |> Enum.flat_map(&split_token_to_fit(&1, font_size, max_width))
  end

  defp split_token_to_fit(token, font_size, max_width) do
    if fits_width?(token, font_size, max_width) do
      [token]
    else
      {chunks, current} =
        token
        |> String.graphemes()
        |> Enum.reduce({[], ""}, fn grapheme, {acc, current} ->
          candidate = current <> grapheme

          cond do
            current == "" ->
              {acc, candidate}

            fits_width?(candidate, font_size, max_width) ->
              {acc, candidate}

            true ->
              {[current | acc], grapheme}
          end
        end)

      chunks = if current == "", do: chunks, else: [current | chunks]
      Enum.reverse(chunks)
    end
  end

  defp wrap_tokens(tokens, font_size, max_width, max_lines) do
    do_wrap_tokens(tokens, font_size, max_width, max_lines, [], "", 0)
  end

  defp do_wrap_tokens([], _font_size, _max_width, max_lines, lines, current, line_count) do
    cond do
      current == "" ->
        {Enum.reverse(lines), []}

      line_count < max_lines ->
        {Enum.reverse([current | lines]), []}

      true ->
        {Enum.reverse(lines), [current]}
    end
  end

  defp do_wrap_tokens(tokens, _font_size, _max_width, max_lines, lines, current, line_count)
       when line_count >= max_lines do
    {Enum.reverse(lines), prepend_if_present(current, tokens)}
  end

  defp do_wrap_tokens([token | rest], font_size, max_width, max_lines, lines, current, line_count) do
    candidate = join_tokens(current, token)

    if fits_width?(candidate, font_size, max_width) do
      do_wrap_tokens(rest, font_size, max_width, max_lines, lines, candidate, line_count)
    else
      cond do
        current == "" and line_count + 1 >= max_lines ->
          {Enum.reverse([token | lines]), rest}

        current == "" ->
          do_wrap_tokens(rest, font_size, max_width, max_lines, [token | lines], "", line_count + 1)

        line_count + 1 >= max_lines ->
          {Enum.reverse([current | lines]), [token | rest]}

        true ->
          do_wrap_tokens(
            rest,
            font_size,
            max_width,
            max_lines,
            [current | lines],
            token,
            line_count + 1
          )
      end
    end
  end

  defp truncate_last_line([], _font_size, _max_width), do: []

  defp truncate_last_line(lines, font_size, max_width) do
    {head, tail} = Enum.split(lines, length(lines) - 1)

    case tail do
      [last] -> head ++ [append_ellipsis_to_fit(last, font_size, max_width)]
      _ -> lines
    end
  end

  defp fit_text_with_ellipsis(text, font_size, max_width) do
    normalized = normalize_text(text)

    cond do
      normalized == "" ->
        ""

      fits_width?(normalized, font_size, max_width) ->
        normalized

      not fits_width?("...", font_size, max_width) ->
        ""

      true ->
        trim_to_fit_with_suffix(normalized, "...", font_size, max_width)
    end
  end

  defp append_ellipsis_to_fit(text, font_size, max_width) do
    normalized = normalize_text(text)

    cond do
      normalized == "" ->
        "..."

      not fits_width?("...", font_size, max_width) ->
        ""

      true ->
        trim_to_fit_with_suffix(normalized, "...", font_size, max_width)
    end
  end

  defp trim_to_fit_with_suffix(text, suffix, font_size, max_width) do
    graphemes = String.graphemes(text)

    0..length(graphemes)
    |> Enum.reduce_while(suffix, fn count, _acc ->
      candidate =
        graphemes
        |> Enum.take(length(graphemes) - count)
        |> Enum.join("")
        |> String.trim()
        |> case do
          "" -> suffix
          value -> value <> suffix
        end

      if fits_width?(candidate, font_size, max_width) do
        {:halt, candidate}
      else
        {:cont, suffix}
      end
    end)
  end

  defp normalize_text(nil), do: ""

  defp normalize_text(text) when is_binary(text) do
    text
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp normalize_text(text), do: normalize_text(to_string(text))

  defp join_tokens("", token), do: token
  defp join_tokens(current, token), do: current <> " " <> token

  defp prepend_if_present("", values), do: values
  defp prepend_if_present(value, values), do: [value | values]

  defp fits_width?(text, font_size, max_width) do
    estimate_line_width(text, font_size) <= max_width
  end

  defp estimate_line_width(text, font_size) do
    text
    |> String.graphemes()
    |> Enum.reduce(0.0, fn grapheme, acc -> acc + glyph_factor(grapheme) * font_size end)
  end

  defp glyph_factor(" "), do: 0.34
  defp glyph_factor("."), do: 0.3
  defp glyph_factor(","), do: 0.3
  defp glyph_factor(":"), do: 0.3
  defp glyph_factor(";"), do: 0.3
  defp glyph_factor("!"), do: 0.34
  defp glyph_factor("|"), do: 0.3
  defp glyph_factor("-"), do: 0.4
  defp glyph_factor("_"), do: 0.45
  defp glyph_factor("/"), do: 0.43
  defp glyph_factor("("), do: 0.37
  defp glyph_factor(")"), do: 0.37
  defp glyph_factor("W"), do: 0.86
  defp glyph_factor("M"), do: 0.82
  defp glyph_factor("I"), do: 0.37

  defp glyph_factor(grapheme) do
    cond do
      String.match?(grapheme, ~r/^[0-9]$/) -> 0.56
      String.match?(grapheme, ~r/^[A-Z]$/) -> 0.63
      String.match?(grapheme, ~r/^[a-z]$/) -> 0.54
      true -> 0.62
    end
  end

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
