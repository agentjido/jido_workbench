defmodule AgentJido.Analytics.PostHog.RuntimeConfigTest do
  use ExUnit.Case, async: true

  alias AgentJido.Analytics.PostHog.RuntimeConfig

  test "defaults to disabled config when env vars are unset" do
    config = RuntimeConfig.resolve(fn _key -> nil end)

    assert config.enabled == false
    assert config.browser_enabled == false
    assert config.server_enabled == false
    assert config.autocapture_enabled == false
    assert config.session_replay_enabled == false
    assert config.session_replay_sample_rate == 0.25
    assert config.api_key == nil
    assert config.api_host == "https://us.i.posthog.com"
    assert config.browser_api_host == "https://us.i.posthog.com"
    assert config.ui_host == "https://us.posthog.com"

    assert RuntimeConfig.posthog_options(config) == [
             enable: false,
             enable_error_tracking: false,
             test_mode: false
           ]
  end

  test "resolves enabled browser and server config from env vars" do
    env = %{
      "POSTHOG_ENABLED" => "true",
      "POSTHOG_BROWSER_ENABLED" => "true",
      "POSTHOG_SERVER_ENABLED" => "true",
      "POSTHOG_AUTOCAPTURE_ENABLED" => "true",
      "POSTHOG_SESSION_REPLAY_ENABLED" => "true",
      "POSTHOG_SESSION_REPLAY_SAMPLE_RATE" => "0.4",
      "POSTHOG_API_KEY" => "phc_test_key",
      "POSTHOG_API_HOST" => "https://us.i.posthog.com",
      "POSTHOG_BROWSER_API_HOST" => "https://e.jido.run"
    }

    config = RuntimeConfig.resolve(&Map.get(env, &1))

    assert config.enabled == true
    assert config.browser_enabled == true
    assert config.server_enabled == true
    assert config.autocapture_enabled == true
    assert config.session_replay_enabled == true
    assert config.session_replay_sample_rate == 0.4
    assert config.api_key == "phc_test_key"
    assert config.api_host == "https://us.i.posthog.com"
    assert config.browser_api_host == "https://e.jido.run"
    assert config.ui_host == "https://us.posthog.com"

    assert RuntimeConfig.posthog_options(config) == [
             enable: true,
             enable_error_tracking: false,
             test_mode: false,
             api_key: "phc_test_key",
             api_host: "https://us.i.posthog.com",
             in_app_otp_apps: [:agent_jido]
           ]
  end

  test "prefers explicit PostHog UI host when configured" do
    env = %{
      "POSTHOG_ENABLED" => "true",
      "POSTHOG_BROWSER_ENABLED" => "true",
      "POSTHOG_API_KEY" => "phc_test_key",
      "POSTHOG_BROWSER_API_HOST" => "https://e.jido.run",
      "POSTHOG_UI_HOST" => "https://us.posthog.com"
    }

    config = RuntimeConfig.resolve(&Map.get(env, &1))

    assert config.browser_api_host == "https://e.jido.run"
    assert config.ui_host == "https://us.posthog.com"
  end

  test "raises when capture is enabled without an API key" do
    env = %{
      "POSTHOG_ENABLED" => "true",
      "POSTHOG_BROWSER_ENABLED" => "true"
    }

    assert_raise RuntimeError, ~r/POSTHOG_API_KEY is required/, fn ->
      RuntimeConfig.resolve(&Map.get(env, &1))
    end
  end
end
