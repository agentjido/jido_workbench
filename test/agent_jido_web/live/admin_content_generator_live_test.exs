defmodule AgentJidoWeb.AdminContentGeneratorLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.ContentPlan

  defmodule ContentGenRunStub do
    def run(_opts) do
      {:ok,
       %{
         run_id: "run_test_ui_123",
         generated_at: DateTime.utc_now(),
         report_path: "tmp/content_gen/runs/run_test_ui_123/report.json",
         stats: %{
           selected: 1,
           written: 0,
           dry_run_candidates: 1,
           audit_failed: 0
         }
       }}
    end
  end

  setup %{conn: conn} do
    original_run_module = Application.get_env(:agent_jido, :content_gen_run_module)
    Application.put_env(:agent_jido, :content_gen_run_module, ContentGenRunStub)

    admin_conn = log_in_user(conn, admin_user_fixture())

    on_exit(fn ->
      if original_run_module do
        Application.put_env(:agent_jido, :content_gen_run_module, original_run_module)
      else
        Application.delete_env(:agent_jido, :content_gen_run_module)
      end
    end)

    %{admin_conn: admin_conn}
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard/content-generator")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard/content-generator")
  end

  test "renders queue and generator form", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard/content-generator")

    assert html =~ "Content Generator"
    assert has_element?(view, "form[phx-submit='start_content_run']")
    assert has_element?(view, "h2", "Draft queue")
    assert has_element?(view, "h2", "Outline queue")

    has_outline_entry? =
      ContentPlan.all_entries()
      |> Enum.any?(&(&1.destination_collection == :pages and &1.status == :outline))

    if has_outline_entry? do
      assert has_element?(view, "button[phx-click='use_entry']", "Use entry")
    else
      assert html =~ "No `:outline` entries found"
    end
  end

  test "clicking queue entry prefills entry id", %{admin_conn: admin_conn} do
    outline_entry =
      ContentPlan.all_entries()
      |> Enum.filter(&(&1.destination_collection == :pages and &1.status == :outline))
      |> Enum.sort_by(&{&1.section, &1.order, &1.id})
      |> List.first()

    assert outline_entry

    {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator")

    view
    |> element("button[phx-click='use_entry'][phx-value-entry='#{outline_entry.id}']")
    |> render_click()

    assert render(view) =~ ~s(name="generator[entry]" value="#{outline_entry.id}")
  end

  test "allows admin to trigger content generation run from dedicated page", %{admin_conn: admin_conn} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator")

    view
    |> form("form[phx-submit='start_content_run']",
      generator: %{
        entry: "docs/reference-jido-action",
        sections: "docs",
        statuses: "outline,draft",
        max: "1",
        backend: "auto",
        model: "",
        update_mode: "improve",
        source_root: "..",
        report: "",
        apply: "false",
        fail_on_audit: "true"
      }
    )
    |> render_submit()

    assert_eventually(fn ->
      html = render(view)
      html =~ "run_test_ui_123" and html =~ "completed" and html =~ "selected: 1"
    end)
  end

  defp assert_eventually(fun, attempts \\ 20)

  defp assert_eventually(fun, attempts) when attempts > 0 do
    if fun.() do
      :ok
    else
      Process.sleep(25)
      assert_eventually(fun, attempts - 1)
    end
  end

  defp assert_eventually(_fun, 0) do
    flunk("expected condition to become true")
  end
end
