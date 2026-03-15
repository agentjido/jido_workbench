defmodule AgentJido.Community.Showcase do
  @moduledoc """
  Static community project showcase powered by NimblePublisher.

  Compiles structured Markdown entries from `priv/community_showcase/` into
  project cards for the `/community/showcase` page.
  """

  alias AgentJido.Community.Showcase.Project

  use NimblePublisher,
    build: Project,
    from: Application.app_dir(:agent_jido, "priv/community_showcase/**/*.md"),
    as: :projects,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html]

  @all_projects Enum.sort_by(@projects, fn project ->
                  {
                    if(project.status == :live, do: 0, else: 1),
                    if(project.featured, do: 0, else: 1),
                    project.sort_order,
                    String.downcase(project.title)
                  }
                end)
  @projects Enum.filter(@all_projects, &(&1.status == :live))

  @all_projects_by_slug Map.new(@all_projects, &{&1.slug, &1})
  @projects_by_slug Map.new(@projects, &{&1.slug, &1})

  defmodule NotFoundError do
    @moduledoc """
    Raised when a showcase project cannot be found.
    """
    defexception [:message, plug_status: 404]
  end

  @doc """
  Returns all live showcase projects.
  """
  @spec all_projects() :: nonempty_list(Project.t())
  def all_projects, do: @projects

  @doc """
  Returns showcase projects with optional draft inclusion.
  """
  @spec all_projects(keyword()) :: nonempty_list(Project.t())
  def all_projects(opts) when is_list(opts) do
    if include_drafts?(opts), do: @all_projects, else: @projects
  end

  @doc """
  Returns live featured projects.
  """
  @spec featured_projects() :: [Project.t()]
  def featured_projects, do: Enum.filter(@projects, & &1.featured)

  @doc """
  Returns featured projects with optional draft inclusion.
  """
  @spec featured_projects(keyword()) :: [Project.t()]
  def featured_projects(opts) when is_list(opts) do
    all_projects(opts) |> Enum.filter(& &1.featured)
  end

  @doc """
  Gets a project by slug, or nil when not found.
  """
  @spec get_project(String.t()) :: Project.t() | nil
  def get_project(slug), do: Map.get(@projects_by_slug, slug)

  @doc """
  Gets a project by slug with optional draft inclusion.
  """
  @spec get_project(String.t(), keyword()) :: Project.t() | nil
  def get_project(slug, opts) when is_list(opts) do
    if include_drafts?(opts) do
      Map.get(@all_projects_by_slug, slug)
    else
      Map.get(@projects_by_slug, slug)
    end
  end

  @doc """
  Gets a project by slug or raises `NotFoundError`.
  """
  @spec get_project!(String.t()) :: Project.t()
  def get_project!(slug) do
    get_project(slug) || raise NotFoundError, "showcase project with slug=#{slug} not found"
  end

  @doc """
  Gets a project by slug with optional draft inclusion, or raises `NotFoundError`.
  """
  @spec get_project!(String.t(), keyword()) :: Project.t()
  def get_project!(slug, opts) when is_list(opts) do
    get_project(slug, opts) || raise NotFoundError, "showcase project with slug=#{slug} not found"
  end

  @doc """
  Returns the count of visible showcase projects.
  """
  @spec project_count() :: non_neg_integer()
  def project_count, do: length(@projects)

  @doc """
  Returns the project count with optional draft inclusion.
  """
  @spec project_count(keyword()) :: non_neg_integer()
  def project_count(opts) when is_list(opts) do
    if include_drafts?(opts), do: length(@all_projects), else: length(@projects)
  end

  defp include_drafts?(opts) do
    Keyword.get(opts, :include_drafts, false) or Keyword.get(opts, :include_unpublished, false)
  end
end
