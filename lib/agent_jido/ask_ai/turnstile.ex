defmodule AgentJido.AskAi.Turnstile do
  @moduledoc """
  Cloudflare Turnstile verification for Ask AI submissions.
  """

  @siteverify_url "https://challenges.cloudflare.com/turnstile/v0/siteverify"
  @default_timeout_ms 5_000

  @type verify_error ::
          :missing_token
          | :not_configured
          | {:invalid_token, [String.t()]}
          | {:request_failed, term()}
          | {:unexpected_response, term()}

  @doc """
  Verifies a Turnstile token.

  `remote_ip` is optional.
  """
  @spec verify(String.t() | nil, String.t() | nil, keyword()) :: :ok | {:error, verify_error()}
  def verify(token, remote_ip, opts \\ []) do
    token = normalize_token(token)
    secret = Keyword.get(opts, :secret, turnstile_secret_key())
    request_fun = Keyword.get(opts, :request_fun, &request_siteverify/2)

    cond do
      token == "" ->
        {:error, :missing_token}

      not is_binary(secret) or secret == "" ->
        {:error, :not_configured}

      true ->
        payload = build_payload(secret, token, remote_ip)

        case request_fun.(payload, opts) do
          {:ok, %{"success" => true}} ->
            :ok

          {:ok, %{"success" => false} = response} ->
            {:error, {:invalid_token, normalize_error_codes(response["error-codes"])}}

          {:ok, other} ->
            {:error, {:unexpected_response, other}}

          {:error, reason} ->
            {:error, {:request_failed, reason}}
        end
    end
  end

  @doc """
  Configured public site key for Turnstile widget rendering.
  """
  @spec turnstile_site_key() :: String.t() | nil
  def turnstile_site_key do
    ask_ai_cfg()
    |> config_value(:turnstile_site_key)
    |> normalize_optional_string()
  end

  @doc """
  Configured secret key used for server-side token verification.
  """
  @spec turnstile_secret_key() :: String.t() | nil
  def turnstile_secret_key do
    ask_ai_cfg()
    |> config_value(:turnstile_secret_key)
    |> normalize_optional_string()
  end

  defp request_siteverify(payload, opts) do
    timeout_ms = Keyword.get(opts, :timeout_ms, @default_timeout_ms)
    finch_name = Keyword.get(opts, :finch, AgentJido.Finch)

    body = URI.encode_query(payload)

    request =
      Finch.build(
        :post,
        @siteverify_url,
        [{"content-type", "application/x-www-form-urlencoded"}],
        body
      )

    case Finch.request(request, finch_name, receive_timeout: timeout_ms) do
      {:ok, %Finch.Response{status: status, body: response_body}} when status in 200..299 ->
        Jason.decode(response_body)

      {:ok, %Finch.Response{status: status, body: response_body}} ->
        {:error, {:http_status, status, response_body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_payload(secret, token, remote_ip) do
    base = %{"secret" => secret, "response" => token}

    case normalize_optional_string(remote_ip) do
      nil -> base
      ip -> Map.put(base, "remoteip", ip)
    end
  end

  defp normalize_token(token) when is_binary(token), do: String.trim(token)
  defp normalize_token(_token), do: ""

  defp normalize_optional_string(value) when is_binary(value) do
    case String.trim(value) do
      "" -> nil
      string -> string
    end
  end

  defp normalize_optional_string(_value), do: nil

  defp normalize_error_codes(codes) when is_list(codes) do
    codes
    |> Enum.map(&to_string/1)
    |> Enum.uniq()
  end

  defp normalize_error_codes(_codes), do: []

  defp ask_ai_cfg do
    Application.get_env(:agent_jido, AgentJido.AskAi, [])
  end

  defp config_value(config, key) when is_list(config), do: Keyword.get(config, key)
  defp config_value(config, key) when is_map(config), do: Map.get(config, key)
  defp config_value(_config, _key), do: nil
end
