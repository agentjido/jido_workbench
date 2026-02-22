defmodule AgentJidoWeb.SitePresenceTest do
  use AgentJidoWeb.ConnCase, async: false

  alias AgentJidoWeb.Presence
  alias AgentJidoWeb.SitePresence

  test "snapshot distinguishes unique visitors from total sessions" do
    topic = SitePresence.topic()
    key = "visitor:test-#{System.unique_integer([:positive])}"
    baseline = SitePresence.snapshot()

    assert {:ok, _meta} = Presence.track(self(), topic, key, %{connected_at: "test:self"})

    parent = self()

    pid =
      spawn_link(fn ->
        Presence.track(self(), topic, key, %{connected_at: "test:other"})
        send(parent, :tracked_other_session)

        receive do
          :stop -> :ok
        end
      end)

    assert_receive :tracked_other_session, 500

    assert_eventually(fn ->
      snapshot = SitePresence.snapshot()

      snapshot.active_visitors >= baseline.active_visitors + 1 and
        snapshot.active_sessions >= baseline.active_sessions + 2
    end)

    send(pid, :stop)
    Presence.untrack(self(), topic, key)
  end

  defp assert_eventually(fun, attempts \\ 30)

  defp assert_eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(25)
      assert_eventually(fun, attempts - 1)
    end
  end

  defp assert_eventually(_fun, 0), do: flunk("expected condition to become true")
end
