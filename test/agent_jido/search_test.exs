defmodule AgentJido.SearchTest do
  use ExUnit.Case, async: true

  alias AgentJido.Search
  alias AgentJido.Search.Result

  describe "query/2" do
    test "returns empty results for empty queries without calling backend" do
      search_fun = fn _query, _opts ->
        flunk("expected blank query to short-circuit without backend call")
      end

      assert {:ok, []} = Search.query("   ", search_fun: search_fun)
    end

    test "returns normalized cross-collection results" do
      rows = [
        %{document_id: "doc-1", text: "docs snippet", score: 0.9},
        %{document_id: "doc-2", text: "blog snippet", score: 0.7},
        %{document_id: "doc-3", text: "ecosystem snippet"}
      ]

      search_fun = fn query, opts ->
        send(self(), {:search_call, query, opts})
        {:ok, rows}
      end

      document_lookup_fun = fn fetched_rows, _repo ->
        send(self(), {:lookup_call, fetched_rows})

        %{
          "doc-1" => %{
            collection: "site_docs",
            source_id: "docs:/docs/getting-started",
            metadata: %{"title" => "Getting Started", "path" => "/docs/getting-started"}
          },
          "doc-2" => %{
            collection: "site_blog",
            source_id: "blog:release-notes",
            metadata: %{"title" => "Release Notes", "id" => "release-notes", "url" => "/blog/release-notes"}
          },
          "doc-3" => %{
            collection: "site_ecosystem",
            source_id: "ecosystem:jido-core",
            metadata: %{"title" => "Jido Core", "id" => "jido-core"}
          }
        }
      end

      assert {:ok, results} =
               Search.query("arcana", search_fun: search_fun, document_lookup_fun: document_lookup_fun, repo: :repo)

      assert_received {:search_call, "arcana", search_opts}
      assert search_opts[:mode] == :hybrid
      assert search_opts[:collections] == Search.collections()

      assert_received {:lookup_call, ^rows}

      assert results == [
               %Result{
                 title: "Getting Started",
                 snippet: "docs snippet",
                 url: "/docs/getting-started",
                 source_type: :docs,
                 score: 0.9
               },
               %Result{
                 title: "Release Notes",
                 snippet: "blog snippet",
                 url: "/blog/release-notes",
                 source_type: :blog,
                 score: 0.7
               },
               %Result{
                 title: "Jido Core",
                 snippet: "ecosystem snippet",
                 url: "/ecosystem#jido-core",
                 source_type: :ecosystem,
                 score: nil
               }
             ]
    end

    test "resolves metadata when Arcana rows use binary UUID document ids" do
      doc_uuid = Ecto.UUID.generate()
      doc_uuid_binary = Ecto.UUID.dump!(doc_uuid)

      rows = [
        %{document_id: doc_uuid_binary, text: "docs snippet", score: 0.9}
      ]

      search_fun = fn _query, _opts -> {:ok, rows} end

      document_lookup_fun = fn _fetched_rows, _repo ->
        %{
          doc_uuid => %{
            collection: "site_docs",
            source_id: "docs:/docs/getting-started",
            metadata: %{"title" => "Getting Started", "path" => "/docs/getting-started"}
          }
        }
      end

      assert {:ok, [%Result{} = result]} =
               Search.query("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 repo: :repo
               )

      assert result.title == "Getting Started"
      assert result.url == "/docs/getting-started"
      assert result.source_type == :docs
    end

    test "derives an internal route from chunk text when metadata lookup is unavailable" do
      doc_uuid_binary = Ecto.UUID.dump!(Ecto.UUID.generate())

      rows = [
        %{
          document_id: doc_uuid_binary,
          text: "Getting Started\n\n/docs/getting-started\n\nJido basics",
          score: 0.7
        }
      ]

      search_fun = fn _query, _opts -> {:ok, rows} end
      document_lookup_fun = fn _fetched_rows, _repo -> %{} end

      assert {:ok, [%Result{} = result]} =
               Search.query("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 repo: :repo
               )

      assert result.url == "/docs/getting-started"
    end

    test "normalizes same-site absolute metadata urls to in-site paths" do
      rows = [
        %{document_id: "doc-1", text: "docs snippet", score: 0.9}
      ]

      search_fun = fn _query, _opts -> {:ok, rows} end

      document_lookup_fun = fn _fetched_rows, _repo ->
        %{
          "doc-1" => %{
            collection: "site_docs",
            source_id: "docs:/docs/getting-started",
            metadata: %{
              "title" => "Getting Started",
              "url" => "https://agentjido.xyz/docs/getting-started#intro"
            }
          }
        }
      end

      assert {:ok, [%Result{} = result]} =
               Search.query("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 repo: :repo
               )

      assert result.url == "/docs/getting-started"
    end

    test "returns empty results when backend returns no rows" do
      search_fun = fn _query, _opts -> {:ok, []} end

      assert {:ok, []} =
               Search.query(
                 "does-not-exist",
                 search_fun: search_fun,
                 document_lookup_fun: fn _rows, _repo -> %{} end
               )
    end

    test "filters retired training routes from backend results" do
      rows = [
        %{document_id: "doc-training", text: "old training snippet", score: 0.9},
        %{document_id: "doc-docs", text: "docs snippet", score: 0.7}
      ]

      search_fun = fn _query, _opts -> {:ok, rows} end

      document_lookup_fun = fn _rows, _repo ->
        %{
          "doc-training" => %{
            collection: "site_docs",
            source_id: "docs:/training/agent-fundamentals",
            metadata: %{"title" => "Training Fundamentals", "path" => "/training/agent-fundamentals"}
          },
          "doc-docs" => %{
            collection: "site_docs",
            source_id: "docs:/docs/getting-started",
            metadata: %{"title" => "Getting Started", "path" => "/docs/getting-started"}
          }
        }
      end

      assert {:ok, results} =
               Search.query("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 repo: :repo
               )

      assert Enum.all?(results, fn result -> not String.starts_with?(result.url, "/training") end)
      assert Enum.any?(results, fn result -> result.url == "/docs/getting-started" end)
    end

    test "falls back when backend results are only retired routes" do
      rows = [%{document_id: "doc-training", text: "old training snippet", score: 0.9}]
      search_fun = fn _query, _opts -> {:ok, rows} end

      document_lookup_fun = fn _rows, _repo ->
        %{
          "doc-training" => %{
            collection: "site_docs",
            source_id: "docs:/training/agent-fundamentals",
            metadata: %{"title" => "Training Fundamentals", "path" => "/training/agent-fundamentals"}
          }
        }
      end

      fallback_result = %Result{
        title: "Docs Fallback",
        snippet: "Fallback docs result",
        url: "/docs/fallback",
        source_type: :docs,
        score: 1.0
      }

      fallback_fun = fn _query, _opts -> [fallback_result] end

      assert {:ok, [^fallback_result]} =
               Search.query("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 fallback_fun: fallback_fun,
                 repo: :repo
               )
    end

    test "falls back to empty results on backend error tuple" do
      search_fun = fn _query, _opts -> {:error, :backend_down} end
      fallback_fun = fn _query, _opts -> [] end

      assert {:ok, []} = Search.query("arcana", search_fun: search_fun, fallback_fun: fallback_fun)
    end

    test "falls back to empty results when backend raises" do
      search_fun = fn _query, _opts -> raise "backend crashed" end
      fallback_fun = fn _query, _opts -> [] end

      assert {:ok, []} = Search.query("arcana", search_fun: search_fun, fallback_fun: fallback_fun)
    end
  end

  describe "query_with_status/2" do
    test "returns success status for normal backend responses" do
      search_fun = fn _query, _opts -> {:ok, []} end
      assert {:ok, [], :success} = Search.query_with_status("arcana", search_fun: search_fun)
    end

    test "returns fallback status when backend returns an error" do
      search_fun = fn _query, _opts -> {:error, :backend_down} end
      fallback_fun = fn _query, _opts -> [] end

      assert {:ok, [], :fallback} =
               Search.query_with_status("arcana", search_fun: search_fun, fallback_fun: fallback_fun)
    end

    test "returns success status when backend fails but fallback provides results" do
      search_fun = fn _query, _opts -> {:error, :backend_down} end

      fallback_result = %Result{
        title: "Fallback Match",
        snippet: "Local content fallback result",
        url: "/docs/fallback",
        source_type: :docs,
        score: 1.0
      }

      fallback_fun = fn _query, _opts -> [fallback_result] end

      assert {:ok, [^fallback_result], :success} =
               Search.query_with_status("arcana", search_fun: search_fun, fallback_fun: fallback_fun)
    end

    test "returns fallback status when backend results are fully filtered and no fallback results exist" do
      rows = [%{document_id: "doc-training", text: "old training snippet", score: 0.9}]
      search_fun = fn _query, _opts -> {:ok, rows} end

      document_lookup_fun = fn _rows, _repo ->
        %{
          "doc-training" => %{
            collection: "site_docs",
            source_id: "docs:/training/agent-fundamentals",
            metadata: %{"title" => "Training Fundamentals", "path" => "/training/agent-fundamentals"}
          }
        }
      end

      fallback_fun = fn _query, _opts -> [] end

      assert {:ok, [], :fallback} =
               Search.query_with_status("jido",
                 search_fun: search_fun,
                 document_lookup_fun: document_lookup_fun,
                 fallback_fun: fallback_fun,
                 repo: :repo
               )
    end
  end
end
