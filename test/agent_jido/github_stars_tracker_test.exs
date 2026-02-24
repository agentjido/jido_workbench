defmodule AgentJido.GithubStarsTrackerTest do
  use ExUnit.Case, async: false

  alias AgentJido.GithubStarsTracker

  @table :github_stars_tracker_test_fetches
  @count_table :github_stars_tracker_test_fetch_counts

  defmodule DynamicFetcher do
    @behaviour GithubStarsTracker.Fetcher
    @table :github_stars_tracker_test_fetches
    @count_table :github_stars_tracker_test_fetch_counts

    @impl true
    def fetch_repo_stars(owner, repo, opts) do
      token = Keyword.get(opts, :token)
      :ets.update_counter(@count_table, {owner, repo, token}, {2, 1}, {{owner, repo, token}, 0})

      case lookup_response({owner, repo, token}) || lookup_response({owner, repo}) do
        {:ok, stars} -> {:ok, stars}
        {:error, reason} -> {:error, reason}
        nil -> {:error, :missing_fixture}
      end
    end

    defp lookup_response(key) do
      case :ets.lookup(@table, key) do
        [{^key, value}] -> value
        [] -> nil
      end
    end
  end

  setup do
    if :ets.whereis(@table) != :undefined do
      :ets.delete(@table)
    end

    if :ets.whereis(@count_table) != :undefined do
      :ets.delete(@count_table)
    end

    :ets.new(@table, [:set, :public, :named_table])
    :ets.new(@count_table, [:set, :public, :named_table])

    on_exit(fn ->
      if :ets.whereis(@table) != :undefined do
        :ets.delete(@table)
      end

      if :ets.whereis(@count_table) != :undefined do
        :ets.delete(@count_table)
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

    :ets.insert(@table, {{"agentjido", "jido"}, {:error, :provider_unavailable}})
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

  test "invalid token falls back to anonymous requests and disables token for future fetches" do
    :ets.insert(@table, {{"agentjido", "jido", "bad-token"}, {:error, {:http_error, 401, "Bad credentials"}}})
    :ets.insert(@table, {{"agentjido", "jido", nil}, {:ok, 101}})
    :ets.insert(@table, {{"agentjido", "req_llm", nil}, {:ok, 202}})

    start_supervised!(
      {GithubStarsTracker,
       repos: repos(),
       fetcher: DynamicFetcher,
       refresh_interval_ms: :timer.hours(24),
       min_request_interval_ms: 0,
       use_auth_token: true,
       github_token: "bad-token"}
    )

    assert :ok = GithubStarsTracker.refresh()
    assert %{stars: 101} = GithubStarsTracker.stars_for("jido")
    assert %{stars: 202} = GithubStarsTracker.stars_for("req_llm")

    bad_token_requests =
      :ets.tab2list(@count_table)
      |> Enum.filter(fn {{_owner, _repo, token}, _count} -> token == "bad-token" end)
      |> Enum.map(&elem(&1, 1))
      |> Enum.sum()

    assert bad_token_requests == 1
  end

  test "rate limit error applies cooldown and skips additional fetches during cooldown window" do
    :ets.insert(@table, {{"agentjido", "jido"}, {:error, :rate_limited}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 333}})

    start_supervised!(
      {GithubStarsTracker,
       repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24), min_request_interval_ms: 0, rate_limit_cooldown_ms: 1_000}
    )

    assert :ok = GithubStarsTracker.refresh()
    assert fetch_count("agentjido", "req_llm") == 0

    jido_count_before = fetch_count("agentjido", "jido")
    assert :ok = GithubStarsTracker.refresh()
    assert fetch_count("agentjido", "jido") == jido_count_before
  end

  test "legacy state maps missing newer keys are normalized during refresh" do
    :ets.insert(@table, {{"agentjido", "jido"}, {:ok, 777}})
    :ets.insert(@table, {{"agentjido", "req_llm"}, {:ok, 888}})

    start_supervised!({GithubStarsTracker, repos: repos(), fetcher: DynamicFetcher, refresh_interval_ms: :timer.hours(24)})

    legacy_state = %{
      repos: repos(),
      stars_map: %{},
      last_refresh_at: nil,
      fetcher: DynamicFetcher,
      request_timeout_ms: 10_000,
      refresh_interval_ms: :timer.hours(24)
    }

    :sys.replace_state(GithubStarsTracker, fn _state -> legacy_state end)

    assert :ok = GithubStarsTracker.refresh()
    assert %{stars: 777} = GithubStarsTracker.stars_for("jido")
    assert %{stars: 888} = GithubStarsTracker.stars_for("req_llm")
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

  defp fetch_count(owner, repo, token \\ nil) do
    key = {owner, repo, token}

    case :ets.lookup(@count_table, key) do
      [{^key, count}] -> count
      [] -> 0
    end
  end
end
