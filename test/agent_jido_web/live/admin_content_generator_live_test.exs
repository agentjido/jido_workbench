defmodule AgentJidoWeb.AdminContentGeneratorLiveTest do
  use AgentJidoWeb.ConnCase, async: false

  @moduletag :slow

  import AgentJido.AccountsFixtures
  import Phoenix.LiveViewTest

  alias AgentJido.ContentPlan

  defmodule ContentGenRunStub do
    def run(opts) do
      if is_pid(Application.get_env(:agent_jido, :content_gen_test_pid)) do
        send(Application.get_env(:agent_jido, :content_gen_test_pid), {:content_gen_run_opts, opts})
      end

      runs_root = Application.fetch_env!(:agent_jido, :content_gen_test_runs_root)
      run_id = "run_test_ui_#{System.unique_integer([:positive])}"
      run_dir = Path.join(runs_root, run_id)
      report_path = Path.join(run_dir, "report.json")

      entry_id = opts.entry || "docs/test-entry"
      route = "/" <> String.trim_leading(String.replace(entry_id, "docs/", "docs/"), "/")
      candidate_filename = String.replace(entry_id, "/", "__") <> ".livemd"
      candidate_path = Path.join([run_dir, "candidates", candidate_filename])

      :ok = File.mkdir_p(Path.dirname(candidate_path))

      :ok =
        File.write(
          candidate_path,
          """
          # Candidate

          ```elixir
          IO.puts(:ok)
          ```
          """
        )

      stats = %{
        selected: 1,
        written: if(opts.apply, do: 1, else: 0),
        dry_run_candidates: if(opts.apply, do: 0, else: 1),
        skipped_noop: 0,
        skipped_non_file_target: 0,
        skipped_missing_for_audit: 0,
        audit_only_passed: 0,
        audit_failed: 0,
        generation_failed: 0,
        parse_failed: 0,
        churn_blocked: 0,
        verification_failed: 0
      }

      verification_status = if(opts.verify, do: "passed", else: "skipped")

      report = %{
        run_id: run_id,
        generated_at: DateTime.utc_now(),
        report_path: report_path,
        run_dir: run_dir,
        options: %{
          apply: opts.apply,
          entry: opts.entry,
          max: opts.max,
          statuses: Enum.map(opts.statuses || [], &Atom.to_string/1),
          sections: opts.sections || [],
          backend: Atom.to_string(opts.backend || :auto),
          update_mode: Atom.to_string(opts.update_mode || :improve),
          source_root: opts.source_root,
          report: opts.report,
          fail_on_audit: opts.fail_on_audit,
          verify: opts.verify,
          docs_format: Atom.to_string(opts.docs_format || :tag)
        },
        stats: stats,
        entries: [
          %{
            id: entry_id,
            title: "Stub Entry",
            section: "docs",
            route: route,
            status: if(opts.apply, do: "written", else: "dry_run_candidate"),
            candidate_path: candidate_path,
            target_path: "priv/pages/docs/stub-entry.livemd",
            read_path: "priv/pages/docs/stub-entry.livemd",
            diff: %{
              changed: true,
              old_bytes: 0,
              new_bytes: 42,
              delta_bytes: 42,
              old_lines: 0,
              new_lines: 4,
              delta_lines: 4
            },
            audit: %{errors: [], warnings: [], summary: %{}, score: 1.0},
            verification: %{
              status: verification_status,
              checks: ["audit_only", "route_render", "livebook_test"],
              check_results: %{
                audit_only: "passed",
                route_render: "passed",
                livebook_test: verification_status
              },
              livebook_test_file: nil,
              command_output_excerpt: nil
            }
          }
        ],
        change_requests: []
      }

      :ok = File.mkdir_p(Path.dirname(report_path))
      :ok = File.write(report_path, Jason.encode!(report))

      {:ok,
       %{
         run_id: run_id,
         generated_at: report.generated_at,
         report_path: report_path,
         stats: %{
           selected: 1,
           written: stats.written,
           dry_run_candidates: stats.dry_run_candidates,
           audit_failed: 0,
           verification_failed: 0
         }
       }}
    end
  end

  setup %{conn: conn} do
    docs_entry =
      ContentPlan.all_entries()
      |> Enum.find(&(&1.destination_collection == :pages and &1.section == "docs"))

    assert docs_entry

    non_docs_entry =
      ContentPlan.all_entries()
      |> Enum.find(&(&1.destination_collection == :pages and &1.section != "docs"))

    non_default_status_entry =
      ContentPlan.all_entries()
      |> Enum.find(&(&1.destination_collection == :pages and &1.status not in [:outline, :draft]))

    runs_root = Path.join(System.tmp_dir!(), "content_gen_dashboard_test_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(runs_root)

    fixture_run_id = "fixture_run_1"
    fixture_run_dir = Path.join(runs_root, fixture_run_id)
    fixture_report_path = Path.join(fixture_run_dir, "report.json")
    fixture_candidate_path = Path.join([fixture_run_dir, "candidates", String.replace(docs_entry.id, "/", "__") <> ".livemd"])

    :ok = File.mkdir_p(Path.dirname(fixture_candidate_path))

    :ok =
      File.write(
        fixture_candidate_path,
        """
        # Fixture Candidate

        ```elixir
        :ok
        ```
        """
      )

    fixture_report = %{
      run_id: fixture_run_id,
      generated_at: DateTime.utc_now(),
      report_path: fixture_report_path,
      run_dir: fixture_run_dir,
      options: %{
        apply: false,
        entry: docs_entry.id,
        max: 1,
        statuses: ["outline", "draft"],
        sections: ["docs"],
        backend: "auto",
        model: nil,
        update_mode: "improve",
        source_root: "..",
        report: nil,
        fail_on_audit: true,
        verify: true,
        docs_format: "livemd"
      },
      stats: %{
        selected: 1,
        written: 0,
        dry_run_candidates: 1,
        skipped_noop: 0,
        skipped_non_file_target: 0,
        skipped_missing_for_audit: 0,
        audit_only_passed: 0,
        audit_failed: 0,
        generation_failed: 0,
        parse_failed: 0,
        churn_blocked: 0,
        verification_failed: 0
      },
      entries: [
        %{
          id: docs_entry.id,
          title: docs_entry.title,
          section: docs_entry.section,
          route: docs_entry.destination_route,
          status: "dry_run_candidate",
          candidate_path: fixture_candidate_path,
          target_path: "priv/pages/docs/fixture.livemd",
          read_path: "priv/pages/docs/fixture.livemd",
          diff: %{
            changed: true,
            old_bytes: 10,
            new_bytes: 22,
            delta_bytes: 12,
            old_lines: 1,
            new_lines: 4,
            delta_lines: 3
          },
          audit: %{errors: [], warnings: [], summary: %{}, score: 1.0},
          verification: %{
            status: "passed",
            checks: ["audit_only", "route_render", "livebook_test"],
            check_results: %{
              audit_only: "passed",
              route_render: "passed",
              livebook_test: "passed"
            },
            livebook_test_file: nil,
            command_output_excerpt: nil
          }
        }
      ],
      change_requests: []
    }

    :ok = File.mkdir_p(Path.dirname(fixture_report_path))
    :ok = File.write(fixture_report_path, Jason.encode!(fixture_report))

    original_run_module = Application.get_env(:agent_jido, :content_gen_run_module)
    original_test_pid = Application.get_env(:agent_jido, :content_gen_test_pid)
    original_runs_root = Application.get_env(:agent_jido, :content_gen_test_runs_root)
    original_report_store_opts = Application.get_env(:agent_jido, :content_gen_report_store_opts)

    Application.put_env(:agent_jido, :content_gen_run_module, ContentGenRunStub)
    Application.put_env(:agent_jido, :content_gen_test_pid, self())
    Application.put_env(:agent_jido, :content_gen_test_runs_root, runs_root)
    Application.put_env(:agent_jido, :content_gen_report_store_opts, runs_root: runs_root)

    admin_conn = log_in_user(conn, admin_user_fixture())

    on_exit(fn ->
      File.rm_rf(runs_root)

      if original_run_module do
        Application.put_env(:agent_jido, :content_gen_run_module, original_run_module)
      else
        Application.delete_env(:agent_jido, :content_gen_run_module)
      end

      if original_test_pid do
        Application.put_env(:agent_jido, :content_gen_test_pid, original_test_pid)
      else
        Application.delete_env(:agent_jido, :content_gen_test_pid)
      end

      if original_runs_root do
        Application.put_env(:agent_jido, :content_gen_test_runs_root, original_runs_root)
      else
        Application.delete_env(:agent_jido, :content_gen_test_runs_root)
      end

      if original_report_store_opts do
        Application.put_env(:agent_jido, :content_gen_report_store_opts, original_report_store_opts)
      else
        Application.delete_env(:agent_jido, :content_gen_report_store_opts)
      end
    end)

    %{
      admin_conn: admin_conn,
      docs_entry: docs_entry,
      non_docs_entry: non_docs_entry,
      non_default_status_entry: non_default_status_entry,
      fixture_run_id: fixture_run_id
    }
  end

  test "redirects unauthenticated users to log in", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard/content-generator")
    assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, "/dashboard/content-generator/runs")
  end

  test "blocks authenticated non-admin users", %{conn: conn} do
    conn = log_in_user(conn, user_fixture())

    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard/content-generator")
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, "/dashboard/content-generator/runs")
  end

  test "renders plan page with queue and commands", %{admin_conn: admin_conn} do
    {:ok, view, html} = live(admin_conn, "/dashboard/content-generator")

    assert has_element?(view, "#admin-shell")
    assert has_element?(view, "a[data-admin-nav-path='/dashboard/content-generator'][data-admin-nav-active='true']", "Content Generator")
    assert html =~ "Content Plan Queue"
    assert has_element?(view, "form[phx-submit='start_content_run']")
    assert has_element?(view, "[data-content-gen-command-current]")
    assert has_element?(view, "button[phx-click='entry_action'][phx-value-action='preview']", "Generate Preview")
    assert has_element?(view, "button[phx-click='entry_action'][phx-value-action='apply']", "Apply")
    assert has_element?(view, "[data-content-gen-command-entry]")
  end

  test "renders runs and run detail subpages", %{admin_conn: admin_conn, fixture_run_id: fixture_run_id, docs_entry: docs_entry} do
    {:ok, runs_view, runs_html} = live(admin_conn, "/dashboard/content-generator/runs")
    assert runs_html =~ "Run History"
    assert has_element?(runs_view, "a", "Open Run")

    {:ok, run_view, run_html} = live(admin_conn, "/dashboard/content-generator/runs/#{fixture_run_id}")
    assert run_html =~ "Run Detail"
    assert run_html =~ fixture_run_id
    assert has_element?(run_view, "a", "Open Entry")

    encoded_entry_id = URI.encode_www_form(docs_entry.id)
    {:ok, entry_view, entry_html} = live(admin_conn, "/dashboard/content-generator/entries/#{encoded_entry_id}")
    assert entry_html =~ "Entry Detail"
    assert has_element?(entry_view, "button[phx-click='entry_action'][phx-value-action='apply_verify']", "Apply + Verify")
    assert has_element?(entry_view, "h3", "Diff")
  end

  test "row apply action for docs forces verify and livemd", %{admin_conn: admin_conn, docs_entry: docs_entry} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator")

    view
    |> element("button[phx-click='entry_action'][phx-value-entry='#{docs_entry.id}'][phx-value-action='apply']")
    |> render_click()

    assert_receive {:content_gen_run_opts, run_opts}
    assert run_opts.entry == docs_entry.id
    assert run_opts.max == 1
    assert run_opts.apply == true
    assert run_opts.verify == true
    assert run_opts.docs_format == :livemd
    assert run_opts.statuses == [docs_entry.status]
  end

  test "entry actions pin selected entry status so non-default statuses still run", %{
    admin_conn: admin_conn,
    non_default_status_entry: non_default_status_entry
  } do
    if non_default_status_entry do
      {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator")

      view
      |> element("button[phx-click='entry_action'][phx-value-entry='#{non_default_status_entry.id}'][phx-value-action='preview']")
      |> render_click()

      assert_receive {:content_gen_run_opts, run_opts}
      assert run_opts.entry == non_default_status_entry.id
      assert run_opts.statuses == [non_default_status_entry.status]
    end
  end

  test "apply+verify for non-docs entry surfaces docs-only validation", %{admin_conn: admin_conn, non_docs_entry: non_docs_entry} do
    if non_docs_entry do
      encoded_entry_id = URI.encode_www_form(non_docs_entry.id)
      {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator/entries/#{encoded_entry_id}")

      view
      |> element("button[phx-click='entry_action'][phx-value-entry='#{non_docs_entry.id}'][phx-value-action='apply_verify']")
      |> render_click()

      assert render(view) =~ "Verify is docs-only"
    end
  end

  test "manual run submission still works", %{admin_conn: admin_conn, docs_entry: docs_entry} do
    {:ok, view, _html} = live(admin_conn, "/dashboard/content-generator")

    view
    |> form("form[phx-submit='start_content_run']",
      generator: %{
        entry: docs_entry.id,
        sections: "docs",
        statuses: "outline,draft",
        max: "1",
        backend: "req_llm",
        docs_format: "livemd",
        update_mode: "improve",
        apply: "false",
        verify: "true",
        fail_on_audit: "true"
      }
    )
    |> render_submit()

    assert_receive {:content_gen_run_opts, run_opts}
    assert run_opts.verify == true
    assert run_opts.docs_format == :livemd

    assert_eventually(fn ->
      html = render(view)
      html =~ "Run in progress" or html =~ "Content generation run completed"
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
