defmodule AgentJido.UpstreamSkillCatalogTest do
  use ExUnit.Case, async: true

  alias AgentJido.UpstreamSkillCatalog

  test "exposes the vendored upstream skill counts and support file metadata" do
    assert UpstreamSkillCatalog.count() == 13
    assert UpstreamSkillCatalog.package_count() == 12
    assert UpstreamSkillCatalog.router_count() == 1
    assert UpstreamSkillCatalog.support_file_count() == 24
    assert UpstreamSkillCatalog.skills_root_source_path() == "priv/skills/arrowcircle-jido-skills/skills"
    assert UpstreamSkillCatalog.source_prompt_source_path() == "priv/skills/arrowcircle-jido-skills/source/prompts.md"
  end

  test "maps vendored skill entries to copied source paths and public ecosystem pages when available" do
    entries = UpstreamSkillCatalog.all_entries()
    names = Enum.map(entries, & &1.name)

    assert "jido-skill-router" in names
    assert "jido-action" in names
    assert "req-llm" in names

    router = Enum.find(entries, &(&1.id == "jido-skill-router"))
    assert router.category == :router
    assert router.skill_source_path == "priv/skills/arrowcircle-jido-skills/skills/jido-skill-router/SKILL.md"
    assert router.reference_files == ["priv/skills/arrowcircle-jido-skills/skills/jido-skill-router/references/skill-manifest.yaml"]
    assert router.agent_files == ["priv/skills/arrowcircle-jido-skills/skills/jido-skill-router/agents/openai.yaml"]

    req_llm = Enum.find(entries, &(&1.id == "req-llm"))
    assert req_llm.category == :package
    assert req_llm.ecosystem_package_id == "req_llm"
    assert req_llm.ecosystem_path == "/ecosystem/req_llm"
    assert req_llm.upstream_url == "https://github.com/arrowcircle/jido-skills/tree/main/skills/req-llm"
  end
end
