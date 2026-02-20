# Jido Workbench

Jido Workbench is a Phoenix Application that contains examples and documentation for the Jido AI Agent Frameowrk.

It is deployed to Fly.io at https://agentjido.xyz

You can deploy your own copy to Fly.io by forking the repo.

## Link Audit

Run the site link audit with:

```bash
mix site.link_audit --include-heex
```

Useful variants:

```bash
# Include external URL checks (slower)
mix site.link_audit --include-heex --check-external

# Temporarily allow known hidden route prefixes
mix site.link_audit --include-heex --allow-prefix /training
```

The audit writes a report to `tmp/link_audit_report.md` by default and exits non-zero if blocking issues are found.

Compatibility wrapper:

```bash
scripts/link_audit.sh --include-heex
```
