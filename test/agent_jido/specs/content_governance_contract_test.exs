defmodule AgentJido.Specs.ContentGovernanceContractTest do
  use ExUnit.Case, async: true

  @governance_path Path.expand("../../../specs/content-governance.md", __DIR__)
  @specs_readme_path Path.expand("../../../specs/README.md", __DIR__)

  test "content governance defines ST-CONT-001 publish DoD hard gate" do
    governance = File.read!(@governance_path)

    assert governance =~ "## 11) Canonical Content Publish Definition of Done (ST-CONT-001)"
    assert governance =~ "**Proof alignment requirement.**"
    assert governance =~ "**Placeholder prohibition.**"
    assert governance =~ "**Route/content sync requirement.**"
    assert governance =~ "**Draft-flag removal gate criteria.**"
  end

  test "minimum checks are specified before draft flag removal" do
    governance = File.read!(@governance_path)

    assert governance =~ "### Minimum checks before changing `draft: true` to `draft: false`"
    assert governance =~ "Verify no placeholder markers remain"
    assert governance =~ "Verify all internal links and CTAs resolve"
    assert governance =~ "Verify claims are proof-backed"
    assert governance =~ "Record reviewer sign-off and date"
  end

  test "freshness checklist and cadence are documented and discoverable in specs index" do
    governance = File.read!(@governance_path)
    specs_readme = File.read!(@specs_readme_path)

    assert governance =~ "## 12) Freshness Checklist and Release Cadence (ST-CONT-001)"
    assert governance =~ "### Freshness checklist (required each release window)"
    assert governance =~ "### Release cadence process"

    assert specs_readme =~ "canonical ST-CONT-001 publish hard gate"
  end

  test "governance contract captures publish gate criteria and review evidence" do
    governance = File.read!(@governance_path)

    assert governance =~ "ST-CONT-001"
    assert governance =~ "Proof alignment requirement."
    assert governance =~ "Route/content sync requirement."
    assert governance =~ "Record reviewer sign-off and date"
  end
end
