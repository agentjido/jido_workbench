defmodule AgentJido.Html.CodeEntityDecoder do
  @moduledoc """
  Decodes quote entities inside rendered code blocks.

  We intentionally limit decoding to text nodes inside `<code>` / `<pre>`
  containers so regular prose and HTML attributes remain unchanged.
  """

  @spec decode_quotes_in_code(String.t()) :: String.t()
  def decode_quotes_in_code(html) when is_binary(html) and html != "" do
    html
    |> decode_quotes_for_blocks(~r{(<pre\b[^>]*>.*?</pre>)}is)
    |> decode_quotes_for_blocks(~r{(<code\b[^>]*>.*?</code>)}is)
  end

  def decode_quotes_in_code(html), do: html

  defp decode_quotes_for_blocks(html, pattern) do
    Regex.replace(pattern, html, fn _full, block ->
      decode_quote_entities(block)
    end)
  end

  defp decode_quote_entities(text) do
    text
    |> String.replace("&#x22;", "\"")
    |> String.replace("&#X22;", "\"")
    |> String.replace("&#34;", "\"")
    |> String.replace("&quot;", "\"")
  end
end
