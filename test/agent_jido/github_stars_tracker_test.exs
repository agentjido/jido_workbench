defmodule AgentJido.GithubStarsTrackerTest do
  use ExUnit.Case, async: false

  alias AgentJido.GithubStarsTracker

  @table :github_stars_tracker_test_fetches

  defmodule DynamicFetcher do
    @behaviour GithubStarsTracker.Fetcher

    @impl true
    def fetch_repo_stars(owner, repo, _opts) do
      key = {owner, repo}

      case :ets.lookup(:github_stars_tracker_test_fetches, key) do
        [{^key, {:ok, stars}}] -> {:ok, stars}
        [{^key, {:error, reason}}] -> {:error, reason}
        [] -> {:error, :missing_fixture}
      end
    end
  end

  setup do
    if :ets.whereis(@table) != :undefined do
      :ets.delete(@table)
    end

    :ets.new(@table, [:set, :public, :named_table])

    on_exit(fn ->
      if :ets.whereis(@table) != :undefined do
        :ets.delete(@table)
      end
    end)

    :ok
  end

  test "refresh populates star cache and stars_for/1 returns entries" do
    :ets.insert(@table, {{"agentjido", "jido"}, {:ok, 1_200}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 42}})

    start_supervised!({GithubStarsTracker, repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24)})

    assert :ok = GithubStarsTracker.refresh()

    stars_map = GithubStarsTracker.stars_map()

    assert %{stars: 1_200, updated_at: %DateTime{}} = stars_map["jido"]
    assert %{stars: 42, updated_at: %DateTime{}} = stars_map["req_llm"]
    assert %{stars: 1_200, updated_at: %DateTime{}} = GithubStarsTracker.stars_for("jido")
  end

  test "refresh preserves stale cached values when one repo fetch fails" do
    :ets.insert(@table, {{"agentjido", "jido"}, {:ok, 100}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 50}})

    start_supervised!({GithubStarsTracker, repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24)})

    assert :ok = GithubStarsTracker.refresh()

    initial_jido = GithubStarsTracker.stars_for("jido")
    initial_req_llm = GithubStarsTracker.stars_for("req_llm")
    initial_jido_updated_at = initial_jido.updated_at

    :ets.insert(@table, {{"agentjido", "jido"}, {:error, :rate_limited}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 75}})

    assert :ok = GithubStarsTracker.refresh()

    assert %{stars: 100, updated_at: ^initial_jido_updated_at} = GithubStarsTracker.stars_for("jido")
    assert %{stars: 75} = req_llm = GithubStarsTracker.stars_for("req_llm")
    refute req_llm.updated_at == initial_req_llm.updated_at
  end

  test "stars_for/1 returns nil for unknown package id" do
    start_supervised!({GithubStarsTracker, repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24)})

    assert nil == GithubStarsTracker.stars_for("missing")
  end

  test "per-repo cache timeout expires stale entries while keeping others" do
    :ets.insert(@table, {{"agentjido", "jido"}, {:ok, 100}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 50}})

    start_supervised!(
      {GithubStarsTracker, repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24), repo_cache_timeout_ms: %{"jido" => 1}}
    )

    assert :ok = GithubStarsTracker.refresh()
    Process.sleep(20)

    assert nil == GithubStarsTracker.stars_for("jido")
    assert %{stars: 50} = GithubStarsTracker.stars_for("req_llm")

    stars_map = GithubStarsTracker.stars_map()
    refute Map.has_key?(stars_map, "jido")
    assert Map.has_key?(stars_map, "req_llm")
  end

  test "format_stars/1 compacts large values" do
    assert GithubStarsTracker.format_stars(999) == "999"
    assert GithubStarsTracker.format_stars(1_200) == "1.2k"
    assert GithubStarsTracker.format_stars(15_000) == "15k"
    assert GithubStarsTracker.format_stars(1_500_000) == "1.5M"
  end

  defp repos do
    %{
      "jido" => %{
        owner: "agentjido",
        repo: "jido",
        github_url: "https://github.com/agentjido/jido"
      },
      "req_llm" => %{
        owner: "agentjido",
        repo: "req_llm",
        github_url: "https://github.com/agentjido/req_llm"
      }
    }
  end
end
