defmodule AgentJido.Github.Optional do
  @moduledoc false

  @type module_resolution_error :: {:module_unavailable, module(), atom(), non_neg_integer()}

  @spec build_client(String.t() | nil) :: {:ok, term()} | {:error, :missing_github_token | module_resolution_error()}
  def build_client(token) when is_binary(token) and token != "" do
    case call_module([Tentacat, Client], :new, [%{access_token: token}]) do
      {:error, _reason} = error -> error
      client -> {:ok, client}
    end
  end

  def build_client(_token), do: {:error, :missing_github_token}

  @spec issues_create(term(), String.t(), String.t(), map()) :: term()
  def issues_create(client, owner, repo, payload) do
    call_module([Tentacat, Issues], :create, [client, owner, repo, payload])
  end

  @spec issue_comments_create(term(), String.t(), String.t(), pos_integer(), map()) :: term()
  def issue_comments_create(client, owner, repo, number, payload) do
    call_module([Tentacat, Issues, Comments], :create, [client, owner, repo, number, payload])
  end

  @spec issues_filter(term(), String.t(), String.t(), map()) :: term()
  def issues_filter(client, owner, repo, params) do
    call_module([Tentacat, Issues], :filter, [client, owner, repo, params])
  end

  @spec pulls_filter(term(), String.t(), String.t(), map()) :: term()
  def pulls_filter(client, owner, repo, params) do
    call_module([Tentacat, Pulls], :filter, [client, owner, repo, params])
  end

  @spec pulls_merge(term(), String.t(), String.t(), pos_integer(), map()) :: term()
  def pulls_merge(client, owner, repo, number, params) do
    call_module([Tentacat, Pulls], :merge, [client, owner, repo, number, params])
  end

  @spec webhooks_create(String.t(), String.t(), String.t(), [String.t()], String.t() | nil, term()) :: term()
  def webhooks_create(owner, repo, url, events, secret, client) do
    payload = %{
      owner: owner,
      repo: repo,
      url: url,
      events: events,
      secret: secret
    }

    call_module([Jido, Tools, Github, Webhooks, Create], :run, [payload, %{client: client}])
  end

  @spec webhooks_list(String.t(), String.t(), term()) :: term()
  def webhooks_list(owner, repo, client) do
    call_module([Jido, Tools, Github, Webhooks, List], :run, [%{owner: owner, repo: repo}, %{client: client}])
  end

  defp call_module(parts, function, args) do
    with {:ok, module} <- resolve_module(parts, function, length(args)) do
      apply(module, function, args)
    end
  end

  defp resolve_module(parts, function, arity) do
    module = Module.concat(parts)

    if Code.ensure_loaded?(module) and function_exported?(module, function, arity) do
      {:ok, module}
    else
      {:error, {:module_unavailable, module, function, arity}}
    end
  end
end
