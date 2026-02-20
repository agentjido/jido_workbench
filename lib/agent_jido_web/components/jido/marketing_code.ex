defmodule AgentJidoWeb.Jido.MarketingCode do
  @moduledoc """
  Code block components for Jido marketing pages.
  """
  use AgentJidoWeb, :html

  attr :title, :string, default: nil
  attr :language, :string, default: "elixir"
  attr :code, :string, required: true
  attr :highlight, :boolean, default: true
  attr :class, :string, default: ""

  def code_block(assigns) do
    normalized_code = normalize_code(assigns.code)

    assigns =
      assigns
      |> assign(:normalized_code, normalized_code)
      |> assign(:highlighted_code, highlighted_code(normalized_code, assigns.language, assigns.highlight))

    ~H"""
    <div class={"code-block #{@class}"}>
      <%= if @title do %>
        <div class="code-header">
          <div class="flex gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-accent-green"></span>
          </div>
          <span class="text-[10px] text-muted-foreground">{@title}</span>
        </div>
      <% end %>
      <div class="code-content">
        <%= if @highlighted_code do %>
          {raw(@highlighted_code)}
        <% else %>
          <pre class="p-5 text-[12px] leading-relaxed"><code class={"language-#{@language}"}><%= @normalized_code %></code></pre>
        <% end %>
      </div>
    </div>
    """
  end

  attr :command, :string, required: true
  attr :class, :string, default: ""

  def terminal_command(assigns) do
    ~H"""
    <div class={"code-block code-block-terminal #{@class}"}>
      <div class="code-header">
        <div class="flex gap-2">
          <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
          <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
          <span class="w-2.5 h-2.5 rounded-full bg-accent-green"></span>
        </div>
        <span class="text-[10px] text-muted-foreground">terminal</span>
      </div>
      <div class="terminal-content">
        <span class="terminal-prompt">$</span>
        <span class="terminal-command">{@command}</span>
      </div>
    </div>
    """
  end

  attr :steps, :list, required: true
  attr :class, :string, default: ""

  def install_steps(assigns) do
    ~H"""
    <div class={"space-y-4 #{@class}"}>
      <%= for {step, index} <- Enum.with_index(@steps, 1) do %>
        <div class="flex gap-4 items-start">
          <div class="w-6 h-6 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-xs font-bold shrink-0">
            {index}
          </div>
          <div class="flex-1">
            <p class="text-sm font-medium text-foreground mb-2">{step.title}</p>
            <%= if step[:code] do %>
              <.terminal_command command={step.code} />
            <% end %>
            <%= if step[:description] do %>
              <p class="text-xs text-muted-foreground mt-2">{step.description}</p>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp highlighted_code(_code, _language, false), do: nil

  defp highlighted_code(code, language, true) do
    formatter_options = [css_class: "highlight marketing-highlight language-#{language}"]

    options =
      case lexer_for(language) do
        nil -> [formatter_options: formatter_options]
        lexer -> [lexer: lexer, formatter_options: formatter_options]
      end

    try do
      Makeup.highlight(code, options)
    rescue
      _ -> nil
    end
  end

  defp lexer_for(language) when is_binary(language) do
    case String.downcase(language) do
      "elixir" -> Makeup.Lexers.ElixirLexer
      "js" -> Makeup.Lexers.JsLexer
      "javascript" -> Makeup.Lexers.JsLexer
      "html" -> Makeup.Lexers.HTMLLexer
      _ -> nil
    end
  end

  defp normalize_code(code) when is_binary(code) do
    lines =
      code
      |> String.split("\n")
      |> Enum.drop_while(&blank_line?/1)
      |> drop_trailing_blank_lines()

    indent =
      lines
      |> Enum.reject(&blank_line?/1)
      |> Enum.map(&leading_indent/1)
      |> Enum.min(fn -> 0 end)

    lines
    |> Enum.map(&strip_indent(&1, indent))
    |> Enum.join("\n")
  end

  defp drop_trailing_blank_lines(lines) do
    lines
    |> Enum.reverse()
    |> Enum.drop_while(&blank_line?/1)
    |> Enum.reverse()
  end

  defp blank_line?(line), do: String.trim(line) == ""

  defp leading_indent(line) do
    line
    |> String.replace_prefix(String.trim_leading(line), "")
    |> String.length()
  end

  defp strip_indent(line, indent) do
    {prefix, rest} = String.split_at(line, indent)

    if String.length(prefix) == indent do
      rest
    else
      line
    end
  end
end
