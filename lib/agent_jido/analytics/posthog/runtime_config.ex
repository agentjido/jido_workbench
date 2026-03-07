defmodule AgentJido.Analytics.PostHog.RuntimeConfig do
  @moduledoc """
  Resolves runtime PostHog configuration from environment variables.
  """

  @default_api_host "https://us.i.posthog.com"
  @default_session_replay_sample_rate 0.25

  @type resolved_config :: %{
          enabled: boolean(),
          browser_enabled: boolean(),
          server_enabled: boolean(),
          autocapture_enabled: boolean(),
          session_replay_enabled: boolean(),
          session_replay_sample_rate: float(),
          api_key: String.t() | nil,
          api_host: String.t()
        }

  @spec resolve((String.t() -> String.t() | nil)) :: resolved_config()
  def resolve(env_reader \\ &System.get_env/1) when is_function(env_reader, 1) do
    enabled = env_boolean(env_reader, "POSTHOG_ENABLED", false)
    browser_enabled = enabled and env_boolean(env_reader, "POSTHOG_BROWSER_ENABLED", false)
    server_enabled = enabled and env_boolean(env_reader, "POSTHOG_SERVER_ENABLED", false)
    autocapture_enabled = browser_enabled and env_boolean(env_reader, "POSTHOG_AUTOCAPTURE_ENABLED", false)

    session_replay_enabled =
      browser_enabled and env_boolean(env_reader, "POSTHOG_SESSION_REPLAY_ENABLED", false)

    session_replay_sample_rate =
      env_float(
        env_reader,
        "POSTHOG_SESSION_REPLAY_SAMPLE_RATE",
        @default_session_replay_sample_rate
      )

    api_key = env_string(env_reader, "POSTHOG_API_KEY")
    api_host = env_string(env_reader, "POSTHOG_API_HOST") || @default_api_host

    if (browser_enabled or server_enabled) and blank?(api_key) do
      raise """
      POSTHOG_API_KEY is required when POSTHOG_BROWSER_ENABLED or POSTHOG_SERVER_ENABLED is enabled.
      """
    end

    %{
      enabled: enabled,
      browser_enabled: browser_enabled,
      server_enabled: server_enabled,
      autocapture_enabled: autocapture_enabled,
      session_replay_enabled: session_replay_enabled,
      session_replay_sample_rate: session_replay_sample_rate,
      api_key: api_key,
      api_host: api_host
    }
  end

  @spec posthog_options(resolved_config()) :: keyword()
  def posthog_options(%{server_enabled: true} = config) do
    [
      enable: true,
      enable_error_tracking: false,
      test_mode: false,
      api_key: config.api_key,
      api_host: config.api_host,
      in_app_otp_apps: [:agent_jido]
    ]
  end

  def posthog_options(_config) do
    [
      enable: false,
      enable_error_tracking: false,
      test_mode: false
    ]
  end

  defp env_boolean(env_reader, key, default) do
    case env_string(env_reader, key) do
      nil -> default
      value -> value in ["1", "true", "TRUE", "True", "on", "ON", "yes", "YES"]
    end
  end

  defp env_float(env_reader, key, default) do
    case env_string(env_reader, key) do
      nil ->
        default

      value ->
        case Float.parse(value) do
          {parsed, ""} when parsed >= 0.0 and parsed <= 1.0 -> parsed
          _other -> default
        end
    end
  end

  defp env_string(env_reader, key) do
    case env_reader.(key) do
      value when is_binary(value) ->
        value
        |> String.trim()
        |> case do
          "" -> nil
          trimmed -> trimmed
        end

      _other ->
        nil
    end
  end

  defp blank?(value), do: is_nil(value) or value == ""
end
