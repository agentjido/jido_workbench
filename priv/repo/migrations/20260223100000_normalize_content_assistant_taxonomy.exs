defmodule AgentJido.Repo.Migrations.NormalizeContentAssistantTaxonomy do
  use Ecto.Migration

  def up do
    execute("""
    UPDATE query_logs
    SET source = 'content_assistant'
    WHERE source IN ('search', 'ask_ai');
    """)

    execute("""
    UPDATE query_logs
    SET channel = 'content_assistant_modal'
    WHERE channel IN ('nav_modal', 'ask_ai_modal');
    """)

    execute("""
    UPDATE query_logs
    SET channel = 'content_assistant_page'
    WHERE channel = 'search_page';
    """)

    execute("""
    UPDATE query_logs
    SET channel = 'content_assistant_no_results'
    WHERE channel IN ('search_page_no_results', 'nav_modal_no_results');
    """)

    execute("""
    UPDATE analytics_events
    SET event = 'content_assistant_submitted'
    WHERE event IN ('search_submitted', 'ask_ai_submitted');
    """)

    execute("""
    UPDATE analytics_events
    SET event = 'content_assistant_reference_clicked'
    WHERE event IN ('search_result_clicked', 'ask_ai_citation_clicked');
    """)

    execute("""
    UPDATE analytics_events
    SET source = 'content_assistant'
    WHERE source IN ('search', 'ask_ai');
    """)

    execute("""
    UPDATE analytics_events
    SET channel = 'content_assistant_modal'
    WHERE channel IN ('nav_modal', 'ask_ai_modal');
    """)

    execute("""
    UPDATE analytics_events
    SET channel = 'content_assistant_page'
    WHERE channel = 'search_page';
    """)

    execute("""
    UPDATE analytics_events
    SET channel = 'content_assistant_no_results'
    WHERE channel IN ('search_page_no_results', 'nav_modal_no_results');
    """)

    execute("""
    UPDATE analytics_events
    SET metadata = jsonb_set(COALESCE(metadata, '{}'::jsonb), '{surface}', '"content_assistant"'::jsonb, true)
    WHERE event = 'feedback_submitted'
      AND COALESCE(metadata->>'surface', '') IN ('ask_ai', 'search', 'ask_ai_modal', 'search_modal', 'search_live');
    """)
  end

  def down do
    :ok
  end
end
