defmodule AgentJido.Html.CodeEntityDecoderTest do
  use ExUnit.Case, async: true

  alias AgentJido.Html.CodeEntityDecoder

  test "decodes quote entities only inside code/pre blocks" do
    html = """
    <p>outside &quot;unchanged&quot;</p>
    <pre><code><span class="s">&quot;my_agent&quot;</span></code></pre>
    <p><code>&quot;inline&quot;</code></p>
    """

    decoded = CodeEntityDecoder.decode_quotes_in_code(html)

    assert decoded =~ ~s(outside &quot;unchanged&quot;)
    assert decoded =~ ~s(<span class="s">"my_agent"</span>)
    assert decoded =~ ~s(<code>"inline"</code>)
  end

  test "returns input unchanged when fragment parsing fails" do
    assert CodeEntityDecoder.decode_quotes_in_code("plain text") == "plain text"
  end
end
