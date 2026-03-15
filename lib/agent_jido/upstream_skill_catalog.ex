defmodule AgentJido.UpstreamSkillCatalog do
  @moduledoc """
  Static catalog for the vendored `arrowcircle/jido-skills` package skills.
  """

  alias Jido.AI.Skill.Loader

  @catalog_root Application.app_dir(:agent_jido, "priv/skills/arrowcircle-jido-skills")
  @skills_root Path.join(@catalog_root, "skills")
  @repo_url "https://github.com/arrowcircle/jido-skills"
  @readme_source_path "priv/skills/arrowcircle-jido-skills/README.md"
  @source_prompt_source_path "priv/skills/arrowcircle-jido-skills/source/prompts.md"

  @catalog_files Path.wildcard(Path.join(@catalog_root, "**/*"))
                 |> Enum.filter(&File.regular?/1)
                 |> Enum.sort()

  Enum.each(@catalog_files, &Module.put_attribute(__MODULE__, :external_resource, &1))

  @type category :: :package | :router

  @type entry :: %{
          id: String.t(),
          name: String.t(),
          title: String.t(),
          description: String.t(),
          category: category(),
          skill_source_path: String.t(),
          upstream_url: String.t(),
          ecosystem_package_id: String.t() | nil,
          ecosystem_path: String.t() | nil,
          agent_files: [String.t()],
          reference_files: [String.t()]
        }

  @spec all_entries() :: [entry()]
  def all_entries do
    skill_paths()
    |> Enum.map(&build_entry!/1)
  end

  @spec package_entries() :: [entry()]
  def package_entries do
    Enum.filter(all_entries(), &(&1.category == :package))
  end

  @spec router_entries() :: [entry()]
  def router_entries do
    Enum.filter(all_entries(), &(&1.category == :router))
  end

  @spec count() :: non_neg_integer()
  def count, do: length(all_entries())

  @spec package_count() :: non_neg_integer()
  def package_count, do: length(package_entries())

  @spec router_count() :: non_neg_integer()
  def router_count, do: length(router_entries())

  @spec repo_url() :: String.t()
  def repo_url, do: @repo_url

  @spec readme_source_path() :: String.t()
  def readme_source_path, do: @readme_source_path

  @spec source_prompt_source_path() :: String.t()
  def source_prompt_source_path, do: @source_prompt_source_path

  @spec skills_root_source_path() :: String.t()
  def skills_root_source_path, do: "priv/skills/arrowcircle-jido-skills/skills"

  @spec support_file_count() :: non_neg_integer()
  def support_file_count do
    all_entries()
    |> Enum.map(&(length(&1.agent_files) + length(&1.reference_files)))
    |> Enum.sum()
  end

  defp build_entry!(skill_path) do
    {:ok, spec} = Loader.load(skill_path)

    skill_dir = Path.dirname(skill_path)
    id = Path.basename(skill_dir)
    category = if id == "jido-skill-router", do: :router, else: :package
    ecosystem_package_id = ecosystem_package_id(id, category)
    ecosystem_path = ecosystem_path(ecosystem_package_id)

    %{
      id: id,
      name: spec.name,
      title: title_for(id, category),
      description: spec.description,
      category: category,
      skill_source_path: relative_to_cwd(skill_path),
      upstream_url: "#{@repo_url}/tree/main/skills/#{id}",
      ecosystem_package_id: ecosystem_package_id,
      ecosystem_path: ecosystem_path,
      agent_files: support_files(skill_dir, "agents"),
      reference_files: support_files(skill_dir, "references")
    }
  end

  defp support_files(skill_dir, subdir) do
    skill_dir
    |> Path.join("#{subdir}/**/*")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&relative_to_cwd/1)
    |> Enum.sort()
  end

  defp skill_paths do
    @skills_root
    |> Path.join("*/SKILL.md")
    |> Path.wildcard()
    |> Enum.sort()
  end

  defp ecosystem_package_id(_id, :router), do: nil
  defp ecosystem_package_id(id, :package), do: String.replace(id, "-", "_")

  defp ecosystem_path(nil), do: nil

  defp ecosystem_path(package_id) do
    if AgentJido.Ecosystem.get_public_package(package_id) do
      "/ecosystem/#{package_id}"
    else
      nil
    end
  end

  defp title_for(_id, :router), do: "Jido Skill Router"

  defp title_for("llm-db", :package), do: "LLM DB"
  defp title_for("req-llm", :package), do: "Req LLM"

  defp title_for(id, :package) do
    id
    |> String.split("-")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp relative_to_cwd(path), do: Path.relative_to(path, Application.app_dir(:agent_jido))
end
