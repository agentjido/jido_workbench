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

    test "returns empty results when backend returns no rows" do
      search_fun = fn _query, _opts -> {:ok, []} end

      assert {:ok, []} =
               Search.query(
                 "does-not-exist",
                 search_fun: search_fun,
                 document_lookup_fun: fn _rows, _repo -> %{} end
               )
    end

    test "falls back to empty results on backend error tuple" do
      search_fun = fn _query, _opts -> {:error, :backend_down} end
      assert {:ok, []} = Search.query("arcana", search_fun: search_fun)
    end

    test "falls back to empty results when backend raises" do
      search_fun = fn _query, _opts -> raise "backend crashed" end
      assert {:ok, []} = Search.query("arcana", search_fun: search_fun)
    end
  end

  describe "query_with_status/2" do
    test "returns success status for normal backend responses" do
      search_fun = fn _query, _opts -> {:ok, []} end
      assert {:ok, [], :success} = Search.query_with_status("arcana", search_fun: search_fun)
    end

    test "returns fallback status when backend returns an error" do
      search_fun = fn _query, _opts -> {:error, :backend_down} end
      assert {:ok, [], :fallback} = Search.query_with_status("arcana", search_fun: search_fun)
    end
  end
end
