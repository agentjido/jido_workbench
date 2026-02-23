defmodule AgentJido.GithubStarsTracker do
  @moduledoc """
  Periodically fetches GitHub star counts for public ecosystem packages and
  serves them from in-memory cache.

  This tracker is intentionally failure-tolerant:

  - fetch errors never crash the process
  - previously cached values are preserved when refreshes fail
  - callers always get a fast, non-blocking read path
  """

  use GenServer

  require Logger

  alias AgentJido.Ecosystem

  @default_refresh_interval_ms :timer.hours(1)
  @default_request_timeout_ms 10_000
  @default_user_agent "AgentJido-GithubStarsTracker"

  @typedoc "Cached star payload for one package."
  @type star_entry :: %{stars: non_neg_integer(), updated_at: DateTime.t()}

  @typedoc "Cached stars indexed by ecosystem package id."
  @type stars_map :: %{optional(String.t()) => star_entry()}

  @typedoc "Normalized GitHub repository metadata for one package."
  @type repo_ref :: %{
          owner: String.t(),
          repo: String.t(),
          github_url: String.t(),
          cache_timeout_ms: pos_integer() | :infinity
        }

  defmodule Fetcher do
    @moduledoc """
    Behaviour for fetching GitHub star counts.
    """

    @callback fetch_repo_stars(owner :: String.t(), repo :: String.t(), opts :: keyword()) ::
                {:ok, non_neg_integer()} | {:error, term()}
  end

  defmodule DefaultFetcher do
    @moduledoc false
    @behaviour AgentJido.GithubStarsTracker.Fetcher

    @impl true
    def fetch_repo_stars(owner, repo, opts) when is_binary(owner) and is_binary(repo) do
      url = "https://api.github.com/repos/#{owner}/#{repo}"
      request_timeout_ms = Keyword.get(opts, :request_timeout_ms, 10_000)
      user_agent = Keyword.get(opts, :user_agent, "AgentJido-GithubStarsTracker")
      token = Keyword.get(opts, :token)

      headers =
        [
          {"Accept", "application/vnd.github+json"},
          {"User-Agent", user_agent}
        ]
        |> maybe_put_auth_header(token)

      request = Finch.build(:get, url, headers)

      case Finch.request(request, AgentJido.Finch, receive_timeout: request_timeout_ms) do
        {:ok, %Finch.Response{status: 200, body: body}} ->
          case Jason.decode(body) do
            {:ok, %{"stargazers_count" => stars}} when is_integer(stars) and stars >= 0 ->
              {:ok, stars}

            {:ok, _other} ->
              {:error, :invalid_response}

            {:error, reason} ->
              {:error, {:invalid_json, reason}}
          end

        {:ok, %Finch.Response{status: status, body: body}} ->
          {:error, {:http_error, status, body}}

        {:error, reason} ->
          {:error, reason}
      end
    end

    defp maybe_put_auth_header(headers, token) when is_binary(token) and token != "" do
      [{"Authorization", "Bearer #{token}"} | headers]
    end

    defp maybe_put_auth_header(headers, _token), do: headers
  end

  @doc """
  Starts the tracker process.

  Supported options:

  - `:name` process name (defaults to module name)
  - `:fetcher` fetcher module implementing `Fetcher`
  - `:request_timeout_ms` HTTP request timeout
  - `:refresh_interval_ms` periodic refresh cadence
  - `:repo_cache_timeout_ms` package-id keyed cache timeout override map
  - `:github_token` optional token override
  - `:repos` optional pre-resolved package->repo map (primarily for tests)
  """
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Returns cached stars indexed by package id.
  """
  @spec stars_map() :: stars_map()
  def stars_map do
    case Process.whereis(__MODULE__) do
      nil -> %{}
      _pid -> GenServer.call(__MODULE__, :stars_map)
    end
  end

  @doc """
  Returns cached stars for one package id.
  """
  @spec stars_for(String.t()) :: star_entry() | nil
  def stars_for(package_id) when is_binary(package_id) do
    case Process.whereis(__MODULE__) do
      nil -> nil
      _pid -> GenServer.call(__MODULE__, {:stars_for, package_id})
    end
  end

  @doc """
  Triggers an immediate refresh.
  """
  @spec refresh() :: :ok
  def refresh do
    case Process.whereis(__MODULE__) do
      nil -> :ok
      _pid -> GenServer.call(__MODULE__, :refresh)
    end
  end

  @doc """
  Formats a star count for compact UI display.

  Examples:

  - `999` => `"999"`
  - `1200` => `"1.2k"`
  - `1500000` => `"1.5M"`
  """
  @spec format_stars(non_neg_integer()) :: String.t()
  def format_stars(stars) when is_integer(stars) and stars >= 0 do
    cond do
      stars >= 1_000_000 ->
        compact(stars / 1_000_000, "M")

      stars >= 1_000 ->
        compact(stars / 1_000, "k")

      true ->
        Integer.to_string(stars)
    end
  end

  @impl true
  def init(opts) do
    repo_cache_timeout_ms =
      Keyword.get(opts, :repo_cache_timeout_ms, config(:repo_cache_timeout_ms, %{}))

    repos =
      Keyword.get_lazy(opts, :repos, fn ->
        build_repo_map(Ecosystem.public_packages(), repo_cache_timeout_ms)
      end)
      |> normalize_repo_timeout_overrides(repo_cache_timeout_ms)

    fetcher = Keyword.get(opts, :fetcher, config(:fetcher, DefaultFetcher))
    request_timeout_ms = Keyword.get(opts, :request_timeout_ms, config(:request_timeout_ms, @default_request_timeout_ms))
    refresh_interval_ms = Keyword.get(opts, :refresh_interval_ms, config(:refresh_interval_ms, @default_refresh_interval_ms))
    github_token = Keyword.get(opts, :github_token, System.get_env("GITHUB_TOKEN"))

    state = %{
      repos: repos,
      stars_map: %{},
      last_refresh_at: nil,
      fetcher: fetcher,
      request_timeout_ms: request_timeout_ms,
      refresh_interval_ms: refresh_interval_ms,
      github_token: github_token
    }

    send(self(), :refresh)
    schedule_refresh(refresh_interval_ms)

    {:ok, state}
  end

  @impl true
  def handle_call(:stars_map, _from, state), do: {:reply, active_stars_map(state), state}

  @impl true
  def handle_call({:stars_for, package_id}, _from, state) do
    {:reply, active_star_for(state, package_id), state}
  end

  @impl true
  def handle_call(:refresh, _from, state) do
    new_state = refresh_stars(state)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info(:refresh, state) do
    schedule_refresh(state.refresh_interval_ms)
    {:noreply, refresh_stars(state)}
  end

  defp config(key, default) do
    :agent_jido
    |> Application.get_env(__MODULE__, [])
    |> Keyword.get(key, default)
  end

  defp schedule_refresh(interval_ms) when is_integer(interval_ms) and interval_ms > 0 do
    Process.send_after(self(), :refresh, interval_ms)
  end

  defp refresh_stars(state) do
    now = DateTime.utc_now()

    {next_stars_map, success_count, failure_count} =
      Enum.reduce(state.repos, {state.stars_map, 0, 0}, fn {package_id, repo_ref}, {acc, success, failure} ->
        fetch_opts = [
          request_timeout_ms: state.request_timeout_ms,
          token: state.github_token,
          user_agent: @default_user_agent
        ]

        case state.fetcher.fetch_repo_stars(repo_ref.owner, repo_ref.repo, fetch_opts) do
          {:ok, stars} when is_integer(stars) and stars >= 0 ->
            updated_entry = %{stars: stars, updated_at: now}
            {Map.put(acc, package_id, updated_entry), success + 1, failure}

          {:error, reason} ->
            Logger.warning(
              "[GithubStarsTracker] fetch failed package=#{package_id} repo=#{repo_ref.owner}/#{repo_ref.repo} reason=#{inspect(reason)}"
            )

            {acc, success, failure + 1}
        end
      end)

    Logger.info("[GithubStarsTracker] refresh complete success=#{success_count} failure=#{failure_count} total=#{map_size(state.repos)}")

    %{state | stars_map: next_stars_map, last_refresh_at: now}
  end

  defp build_repo_map(packages, repo_cache_timeout_ms) when is_list(packages) and is_map(repo_cache_timeout_ms) do
    Enum.reduce(packages, %{}, fn pkg, acc ->
      case package_repo_ref(pkg, Map.get(repo_cache_timeout_ms, pkg.id)) do
        {:ok, repo_ref} -> Map.put(acc, pkg.id, repo_ref)
        :error -> acc
      end
    end)
  end

  defp package_repo_ref(pkg, timeout_override) do
    owner = normalize_text(Map.get(pkg, :github_org))
    repo = normalize_text(Map.get(pkg, :github_repo))
    github_url = normalize_text(Map.get(pkg, :github_url))
    cache_timeout_ms = normalize_cache_timeout(timeout_override)

    cond do
      owner != "" and repo != "" ->
        {:ok, %{owner: owner, repo: repo, github_url: build_repo_url(owner, repo, github_url), cache_timeout_ms: cache_timeout_ms}}

      github_url != "" ->
        case parse_repo_from_url(github_url) do
          {:ok, parsed_owner, parsed_repo} ->
            {:ok, %{owner: parsed_owner, repo: parsed_repo, github_url: github_url, cache_timeout_ms: cache_timeout_ms}}

          :error ->
            :error
        end

      true ->
        :error
    end
  end

  defp parse_repo_from_url(url) when is_binary(url) do
    uri = URI.parse(url)
    host = normalize_text(uri.host || "")

    path_segments =
      uri.path
      |> normalize_text()
      |> String.trim_leading("/")
      |> String.split("/", trim: true)

    case {host, path_segments} do
      {host_name, [owner, repo | _rest]} when host_name in ["github.com", "www.github.com"] ->
        owner = normalize_text(owner)
        repo = normalize_text(repo)

        if owner != "" and repo != "" do
          {:ok, owner, repo}
        else
          :error
        end

      _other ->
        :error
    end
  end

  defp parse_repo_from_url(_), do: :error

  defp build_repo_url(owner, repo, ""), do: "https://github.com/#{owner}/#{repo}"
  defp build_repo_url(_owner, _repo, github_url), do: github_url

  defp normalize_repo_timeout_overrides(repos, repo_cache_timeout_ms) when is_map(repos) and is_map(repo_cache_timeout_ms) do
    Enum.into(repos, %{}, fn {package_id, repo_ref} ->
      effective_timeout =
        repo_ref
        |> Map.get(:cache_timeout_ms, Map.get(repo_cache_timeout_ms, package_id))
        |> normalize_cache_timeout()

      {package_id, Map.put(repo_ref, :cache_timeout_ms, effective_timeout)}
    end)
  end

  defp normalize_cache_timeout(timeout_ms) when is_integer(timeout_ms) and timeout_ms > 0, do: timeout_ms
  defp normalize_cache_timeout(:infinity), do: :infinity
  defp normalize_cache_timeout(_), do: :infinity

  defp active_stars_map(state) do
    now = DateTime.utc_now()

    Enum.reduce(state.stars_map, %{}, fn {package_id, entry}, acc ->
      if stale_entry?(state, package_id, entry, now) do
        acc
      else
        Map.put(acc, package_id, entry)
      end
    end)
  end

  defp active_star_for(state, package_id) when is_binary(package_id) do
    now = DateTime.utc_now()

    case Map.get(state.stars_map, package_id) do
      nil ->
        nil

      entry ->
        if stale_entry?(state, package_id, entry, now), do: nil, else: entry
    end
  end

  defp stale_entry?(state, package_id, entry, now) do
    case timeout_for_repo(state, package_id) do
      :infinity ->
        false

      timeout_ms when is_integer(timeout_ms) and timeout_ms > 0 ->
        DateTime.diff(now, entry.updated_at, :millisecond) > timeout_ms
    end
  end

  defp timeout_for_repo(state, package_id) do
    state.repos
    |> Map.get(package_id, %{})
    |> Map.get(:cache_timeout_ms, :infinity)
    |> normalize_cache_timeout()
  end

  defp normalize_text(nil), do: ""

  defp normalize_text(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  defp normalize_text(value), do: value |> to_string() |> normalize_text()

  defp compact(value, suffix) do
    rounded = Float.round(value, 1)

    number =
      if rounded == trunc(rounded) do
        rounded
        |> trunc()
        |> Integer.to_string()
      else
        :erlang.float_to_binary(rounded, decimals: 1)
      end

    number <> suffix
  end
end
