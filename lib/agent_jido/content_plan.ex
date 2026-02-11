defmodule AgentJido.ContentPlan do
  @moduledoc """
  Rich table of contents and specification registry for planned Jido documentation.

  Powered by NimblePublisher, this module compiles Markdown files from
  `priv/content_plan/` into structured entries at build time. Serves as:

  1. **TODO list** — filter by status, priority, assignee
  2. **LLM specification** — repos, source_modules, learning_outcomes for validation
  3. **Rich TOC** — hierarchical sections with ordering, slugs, cross-references
  """

  alias AgentJido.ContentPlan.Entry
  alias AgentJido.ContentPlan.Section

  use NimblePublisher,
    build: Entry,
    from: Application.app_dir(:agent_jido, "priv/content_plan/**/*.md"),
    as: :all_items,
    highlighters: [:makeup_elixir]

  @sections @all_items
            |> Enum.filter(fn item -> item.slug == "_section" end)
            |> Enum.map(fn item ->
              Section.build(
                item.path,
                %{
                  id: item.section,
                  title: item.title,
                  description: Map.get(item, :purpose, ""),
                  order: item.order,
                  body: item.body,
                  path: item.path
                },
                item.body
              )
            end)
            |> Enum.sort_by(& &1.order)

  @entries @all_items
           |> Enum.reject(fn item -> item.slug == "_section" end)
           |> Enum.sort_by(fn e -> {e.section, e.order, e.slug} end)

  @entries_by_id Map.new(@entries, &{&1.id, &1})

  @entries_by_section @entries
                      |> Enum.group_by(& &1.section)
                      |> Map.new()

  @entries_by_status @entries
                     |> Enum.group_by(& &1.status)
                     |> Map.new()

  @entries_by_repo @entries
                   |> Enum.flat_map(fn e -> Enum.map(e.repos, &{&1, e}) end)
                   |> Enum.group_by(fn {repo, _} -> repo end, fn {_, e} -> e end)
                   |> Map.new()

  @sections_by_id Map.new(@sections, &{&1.id, &1})

  @tags @entries
        |> Enum.flat_map(& &1.tags)
        |> Enum.uniq()
        |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  # --- Sections ---

  @spec all_sections() :: [Section.t()]
  def all_sections, do: @sections

  @spec get_section(String.t()) :: Section.t() | nil
  def get_section(id), do: Map.get(@sections_by_id, id)

  # --- Entries ---

  @spec all_entries() :: [Entry.t()]
  def all_entries, do: @entries

  @spec get_entry(String.t()) :: Entry.t() | nil
  def get_entry(id), do: Map.get(@entries_by_id, id)

  @spec get_entry!(String.t()) :: Entry.t()
  def get_entry!(id) do
    Map.get(@entries_by_id, id) ||
      raise NotFoundError, "content plan entry with id=#{id} not found"
  end

  @spec entries_by_section(String.t()) :: [Entry.t()]
  def entries_by_section(section), do: Map.get(@entries_by_section, section, [])

  @spec entries_by_status(atom()) :: [Entry.t()]
  def entries_by_status(status), do: Map.get(@entries_by_status, status, [])

  @spec entries_by_repo(String.t()) :: [Entry.t()]
  def entries_by_repo(repo), do: Map.get(@entries_by_repo, repo, [])

  @spec all_tags() :: [atom()]
  def all_tags, do: @tags

  @spec entry_count() :: non_neg_integer()
  def entry_count, do: length(@entries)

  # --- Rich TOC ---

  @spec table_of_contents() :: [{Section.t(), [Entry.t()]}]
  def table_of_contents do
    Enum.map(@sections, fn section ->
      entries = entries_by_section(section.id)
      {section, entries}
    end)
  end

  # --- Coverage Report ---

  @spec coverage_report() :: %{
          total: non_neg_integer(),
          by_status: %{atom() => non_neg_integer()},
          by_priority: %{atom() => non_neg_integer()},
          by_section: %{String.t() => non_neg_integer()}
        }
  def coverage_report do
    %{
      total: length(@entries),
      by_status: @entries |> Enum.frequencies_by(& &1.status),
      by_priority: @entries |> Enum.frequencies_by(& &1.priority),
      by_section: @entries |> Enum.frequencies_by(& &1.section)
    }
  end
end
