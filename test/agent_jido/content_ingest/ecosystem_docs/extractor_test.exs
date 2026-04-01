defmodule AgentJido.ContentIngest.EcosystemDocs.ExtractorTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentIngest.EcosystemDocs.Extractor

  test "extracts searchable page text without ExDoc chrome" do
    html = """
    <html>
      <body>
        <main id="main">
          <div id="content">
            <div class="top-search">Search box</div>
            <div id="top-content">
              <h1>Jido.Agent</h1>
            </div>
            <section id="summary">
              <h2>Functions</h2>
              <p>cmd/2 updates agent state.</p>
            </section>
            <div class="bottom-actions">Prev / Next</div>
          </div>
        </main>
      </body>
    </html>
    """

    assert {:ok, extracted} = Extractor.extract(html)
    assert extracted.title == "Jido.Agent"
    assert extracted.text =~ "Functions"
    assert extracted.text =~ "cmd/2 updates agent state."
    refute extracted.text =~ "Search box"
    refute extracted.text =~ "Prev / Next"
  end

  test "extracts canonical urls from response headers" do
    headers = [{"link", ~s(<https://hexdocs.pm/jido/Jido.Agent.html>; rel="canonical")}]

    assert Extractor.canonical_url(headers, "https://hexdocs.pm/jido/2.1.0/Jido.Agent.html") ==
             "https://hexdocs.pm/jido/Jido.Agent.html"
  end
end
