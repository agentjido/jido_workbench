defmodule AgentJido.OGImage.Templates do
  @moduledoc """
  SVG template variants for Open Graph image rendering.
  """

  alias AgentJido.OGImage.Descriptor

  @image_width 1200
  @image_height 630

  @color_bg "#0b0f14"
  @color_text "#f3f7fa"
  @color_text_muted "#9fb0bf"

  @color_primary "#00ff88"
  @color_primary_soft "#6cf3be"
  @color_cyan "#00ccff"
  @color_yellow "#ffb700"
  @color_red "#ff8b8b"

  @layout_content_x 72
  @layout_content_width 1000
  @layout_brand_y 88
  @layout_eyebrow_y 168
  @layout_title_bottom_margin 76

  @title_sizes [84, 76, 68, 60, 54, 48]
  @title_line_height_factor 1.02

  @spec render_svg(Descriptor.t()) :: String.t()
  def render_svg(%Descriptor{} = descriptor), do: minimal_svg(descriptor)

  defp minimal_svg(descriptor) do
    theme = template_theme(descriptor.template)
    title_layout = layout_text(descriptor.title || "", @title_sizes, @layout_content_width, 3)
    title_y = title_anchor_y(title_layout.lines, title_layout.font_size, @title_line_height_factor)

    """
    <svg width="#{@image_width}" height="#{@image_height}" viewBox="0 0 #{@image_width} #{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <rect width="#{@image_width}" height="#{@image_height}" fill="#{@color_bg}" />
      #{brand_lockup(theme.accent)}
      #{eyebrow_label(descriptor.eyebrow || theme.eyebrow, theme.accent)}
      #{text_block_svg(title_layout.lines,
    x: @layout_content_x,
    y: title_y,
    font_size: title_layout.font_size,
    font_weight: 700,
    fill: theme.title_fill,
    line_height_factor: @title_line_height_factor)}
    </svg>
    """
  end

  defp template_theme(:home) do
    %{eyebrow: "JIDO", accent: @color_primary, title_fill: @color_primary_soft}
  end

  defp template_theme(:marketing) do
    %{eyebrow: "JIDO", accent: @color_cyan, title_fill: @color_text}
  end

  defp template_theme(:docs_page) do
    %{eyebrow: "DOCS", accent: @color_cyan, title_fill: @color_text}
  end

  defp template_theme(:blog_post) do
    %{eyebrow: "BLOG POST", accent: @color_primary, title_fill: @color_text}
  end

  defp template_theme(:example) do
    %{eyebrow: "EXAMPLE", accent: @color_yellow, title_fill: @color_text}
  end

  defp template_theme(:ecosystem_package) do
    %{eyebrow: "ECOSYSTEM PACKAGE", accent: @color_yellow, title_fill: @color_text}
  end

  defp template_theme(:not_found) do
    %{eyebrow: "NOT FOUND", accent: @color_red, title_fill: @color_text}
  end

  defp template_theme(_template) do
    %{eyebrow: "JIDO", accent: @color_cyan, title_fill: @color_text}
  end

  defp brand_lockup(accent) do
    """
    <g transform="translate(#{@layout_content_x} #{@layout_brand_y})">
      <rect x="0" y="9" width="12" height="12" rx="3" fill="#{accent}" />
      <text x="24" y="22" font-family="system-ui, -apple-system, sans-serif" font-size="22" font-weight="650" fill="#{@color_text}">
        jido.run
      </text>
    </g>
    """
  end

  defp eyebrow_label(text, accent) do
    """
    <text x="#{@layout_content_x}" y="#{@layout_eyebrow_y}" font-family="system-ui, -apple-system, sans-serif" font-size="16" font-weight="700" fill="#{accent}" letter-spacing="2.2">
      #{escape_text(text)}
    </text>
    <line x1="#{@layout_content_x}" y1="#{@layout_eyebrow_y + 18}" x2="#{@layout_content_x + 120}" y2="#{@layout_eyebrow_y + 18}" stroke="#{@color_text_muted}" stroke-width="2" stroke-linecap="square" />
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

  defp title_anchor_y([], _font_size, _line_height_factor), do: @image_height - @layout_title_bottom_margin

  defp title_anchor_y(lines, font_size, line_height_factor) do
    line_height = round(font_size * line_height_factor)
    consumed_height = max(length(lines) - 1, 0) * line_height

    @image_height - @layout_title_bottom_margin - consumed_height
  end

  defp layout_text(text, font_sizes, max_width, max_lines) do
    case normalize_text(text) do
      "" ->
        %{font_size: List.last(font_sizes), lines: []}

      value ->
        find_best_text_layout(value, font_sizes, max_width, max_lines)
    end
  end

  defp find_best_text_layout(value, font_sizes, max_width, max_lines) do
    case Enum.find_value(font_sizes, &layout_for_font_size(value, &1, max_width, max_lines)) do
      nil ->
        smallest = List.last(font_sizes)
        {lines, _overflow?} = wrap_text(value, smallest, max_width, max_lines, true)
        %{font_size: smallest, lines: lines}

      layout ->
        layout
    end
  end

  defp layout_for_font_size(value, size, max_width, max_lines) do
    {lines, overflow?} = wrap_text(value, size, max_width, max_lines, false)

    if overflow? do
      nil
    else
      %{font_size: size, lines: lines}
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
        |> Enum.reduce({[], ""}, &split_token_grapheme(&1, &2, font_size, max_width))

      finish_split_token(chunks, current)
    end
  end

  defp split_token_grapheme(grapheme, {acc, current}, font_size, max_width) do
    candidate = current <> grapheme

    cond do
      current == "" ->
        {acc, candidate}

      fits_width?(candidate, font_size, max_width) ->
        {acc, candidate}

      true ->
        {[current | acc], grapheme}
    end
  end

  defp finish_split_token(chunks, ""), do: Enum.reverse(chunks)
  defp finish_split_token(chunks, current), do: Enum.reverse([current | chunks])

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
