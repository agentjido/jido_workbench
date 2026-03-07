defmodule AgentJidoWeb.PostHogLayoutTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures

  setup do
    original_posthog_config = Application.get_env(:agent_jido, :posthog)

    on_exit(fn ->
      if original_posthog_config do
        Application.put_env(:agent_jido, :posthog, original_posthog_config)
      else
        Application.delete_env(:agent_jido, :posthog)
      end
    end)

    :ok
  end

  test "injects browser PostHog config on public pages when enabled", %{conn: conn} do
    put_posthog_config(%{})

    html =
      conn
      |> get("/")
      |> html_response(200)

    assert html =~ "window.__agentJidoPostHog"
    assert html =~ ~s("apiKey":"browser-posthog-key")
    assert html =~ ~s("sessionReplaySampleRate":0.25)
    assert html =~ ~s("pathIgnorePrefixes")
  end

  test "does not inject browser PostHog config when disabled", %{conn: conn} do
    put_posthog_config(%{enabled: false, browser_enabled: false})

    html =
      conn
      |> get("/")
      |> html_response(200)

    refute html =~ "window.__agentJidoPostHog"
  end

  test "does not inject browser PostHog config for authenticated admins", %{conn: conn} do
    put_posthog_config(%{})
    admin = admin_user_fixture()

    html =
      conn
      |> log_in_user(admin)
      |> get("/")
      |> html_response(200)

    refute html =~ "window.__agentJidoPostHog"
  end

  test "renders auth forms with PostHog-safe capture classes", %{conn: conn} do
    html =
      conn
      |> get("/users/log-in")
      |> html_response(200)

    assert html =~ "ph-no-capture ph-sensitive"
  end

  defp put_posthog_config(overrides) do
    Application.put_env(
      :agent_jido,
      :posthog,
      Map.merge(
        %{
          enabled: true,
          browser_enabled: true,
          server_enabled: false,
          autocapture_enabled: true,
          session_replay_enabled: true,
          session_replay_sample_rate: 0.25,
          api_key: "browser-posthog-key",
          api_host: "https://us.i.posthog.com"
        },
        overrides
      )
    )
  end
end
