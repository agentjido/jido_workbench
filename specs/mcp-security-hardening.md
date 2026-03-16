# MCP Documentation Server Security Hardening (ST-MCP-SEC-001)

Status: Proposed  
Last updated: 2026-03-16  
Scope: `lib/agent_jido/mcp/*`, `lib/agent_jido_web/controllers/mcp_docs_controller.ex`, `lib/agent_jido/content_ingest/*`, and the public `/mcp/docs` endpoint.

## 1) Problem Statement

The site now exposes a public MCP access point at `/mcp/docs`. That surface is intended to answer documentation questions only, but it currently sits on top of shared retrieval and markdown-resolution layers that can touch broader application data paths.

The hard requirement for this spec is:

- No MCP prompt, tool call, or fallback path may retrieve non-documentation data.
- Retrieved documentation content must be treated as untrusted content, not executable instruction text.
- The public HTTP MCP transport must be safe to expose without creating an indirect prompt injection or data exfiltration path.

## 2) OWASP-Derived Security Principles

This spec adopts the following rules from the OWASP LLM Prompt Injection Prevention Cheat Sheet and MCP Security Cheat Sheet:

- Treat retrieved external or remote content as untrusted data, even when it is first-party content.
- Separate instructions from data and never let tool inputs redefine the server’s security boundary.
- Enforce least privilege for tool access, backing services, and transport exposure.
- Validate inputs before tool execution and validate outputs before returning them to a model host.
- Log and alert on prompt-injection indicators, scope-breakout attempts, and suspicious tool usage.

References:

- OWASP LLM Prompt Injection Prevention Cheat Sheet: <https://cheatsheetseries.owasp.org/cheatsheets/LLM_Prompt_Injection_Prevention_Cheat_Sheet.html>
- OWASP MCP Security Cheat Sheet: <https://cheatsheetseries.owasp.org/cheatsheets/MCP_Security_Cheat_Sheet.html>

## 3) Current Implementation Gaps

The following gaps must be treated as real current-state risks:

1. The Arcana collection named `site_docs` is not truly docs-only today.
- `AgentJido.ContentIngest.Inventory.build_docs/0` currently ingests `Pages.all_pages()` and only excludes `/build` and `/training`.
- This means the MCP search layer is depending on post-query filtering rather than true source isolation.

2. `search_docs` filters to docs routes after retrieval, not before retrieval.
- `AgentJido.MCP.DocsTools.search_docs/2` constrains `collections: ["site_docs"]`, but the underlying collection still includes non-doc pages.
- Result filtering happens in normalization, which is too late to count as data-scope isolation.

3. `get_doc` returns raw markdown for public docs routes.
- `AgentJido.MCP.DocsTools.get_doc/2` delegates to `AgentJidoWeb.MarkdownContent.resolve/2`.
- That can expose source markdown artifacts such as frontmatter, comments, or other model-visible text that was not authored as safe retrieval output.

4. The public HTTP transport is unauthenticated.
- `AgentJidoWeb.MCPDocsController` currently relies on request-size checks and IP-based rate limiting only.
- This is not sufficient as the sole boundary for a DB-backed retrieval surface.

5. Forwarded-IP trust is too permissive.
- `MCPDocsController.client_identifier/1` accepts `x-forwarded-for` and `x-real-ip` from any caller.
- Without trusted proxy enforcement, rate limiting can be bypassed by forged headers.

6. Returned snippets and markdown are not marked or sanitized as untrusted content.
- The current tool result contracts return documentation text directly.
- There is no prompt-injection detection metadata, sanitization flag, or trust boundary marker in tool results.

## 4) Security Objectives

This spec is complete only when all of the following are true:

1. MCP search can only query a docs-only content inventory built from public docs pages.
2. Public HTTP callers cannot use MCP tools to enumerate, infer, or retrieve non-doc content.
3. Public HTTP callers cannot retrieve raw source markdown by default.
4. Returned text is sanitized and labeled as untrusted documentation content.
5. The server records enough telemetry to detect prompt injection attempts and scope-breakout attempts.

## 5) Normative Requirements

### 5.1 Data-Scope Isolation

The MCP docs server must use a dedicated ingestion scope that is provably limited to published docs pages.

Required changes:

1. Introduce a dedicated MCP docs collection.
- The collection must be distinct from the current `site_docs` inventory.
- The collection must be built only from `Pages.pages_by_category(:docs)` or an equivalent docs-only source.
- The collection must exclude non-public, hidden, retired, preview, or draft routes.

2. Enforce source-type and category filters before retrieval.
- MCP search must query only the MCP docs collection.
- Retrieved rows must carry metadata showing `source_type=documentation` and `category=docs`.
- A row that fails either condition must be rejected before scoring or response assembly.

3. Ban client-controlled scope parameters.
- MCP callers must not be able to specify collection names, repo names, categories, source paths, SQL fragments, module names, or arbitrary filters.
- The only allowed search inputs are user text query plus bounded pagination/limit controls.

4. Restrict the DB role used by MCP retrieval.
- The production DB role used by the MCP HTTP endpoint must be read-only.
- It must only be able to read the docs MCP retrieval corpus and required metadata tables.
- It must not have write permissions or read access to unrelated application tables.

### 5.2 Public Tool Surface Minimization

The public HTTP transport must expose the smallest useful tool set.

Required changes:

1. Keep the HTTP tool surface explicitly minimal.
- `search_docs` and `list_sections` may remain public.
- `get_doc` must move to a reduced public mode unless authenticated transport is added.

2. Split `get_doc` into public-safe and trusted modes.
- Public HTTP `get_doc` must return sanitized excerpts plus metadata, not raw markdown source.
- Full markdown payloads may only be returned over local `stdio` or an authenticated transport.

3. Keep resources, prompts, sampling, and mutation tools disabled.
- The docs MCP server must remain tools-only for public HTTP.
- Any future expansion to prompts, resources, or sampling requires a separate security review.

### 5.3 Content Sanitization and Trust Labeling

All model-visible content returned by the MCP server must be treated as untrusted data.

Required changes:

1. Sanitize returned snippet and document text.
- Strip HTML comments, hidden HTML blocks, script/style blocks, and source-only frontmatter from public responses.
- Normalize links to canonical public docs URLs only.
- Truncate content to bounded excerpt sizes for public HTTP responses.

2. Add trust metadata to every text-bearing result.
- Every `search_docs` and `get_doc` response must include:
  - `content_trust: "untrusted_documentation"`
  - `sanitization_applied: true | false`
  - `prompt_injection_flags: []`

3. Add prompt-injection pattern detection for returned content.
- The server must scan returned documentation text for known instruction-like phrases and suspicious control patterns.
- Detection must not execute blocking logic by keyword alone, but it must annotate and log flagged results.

### 5.4 Input Policy and Scope-Breakout Detection

Prompt-injection defense must be enforced at the MCP tool boundary, not delegated to the client.

Required changes:

1. Add breakout-intent detection for MCP requests.
- Requests attempting to access tokens, secrets, system prompts, environment variables, database tables, or non-doc path prefixes must be blocked or downgraded before tool execution.
- Block decisions must be based on explicit boundary violations, not generic keyword matching alone.

2. Tighten path handling.
- `get_doc` must only accept canonical or legacy public docs paths that resolve to a published docs page.
- Requests for `/blog`, `/ecosystem`, `/community`, `/search`, `/build`, `/training`, or any non-doc route must fail with the same generic not-found response.

3. Reduce response detail on denied requests.
- Error bodies must not reveal collection names, internal table names, internal source paths, or implementation details.

### 5.5 HTTP Transport Security

The public HTTP transport must have explicit production controls.

Required changes:

1. Add a production enable flag.
- Public HTTP MCP must be disabled by default in production.
- Enabling public HTTP MCP must require an explicit config flag and security sign-off.

2. Strengthen rate limiting and identity handling.
- Trust `x-forwarded-for` and `x-real-ip` only when the request passed through a configured trusted proxy.
- Otherwise use `conn.remote_ip`.
- Apply per-tool and per-client rate limits, not one shared bucket only.

3. Enforce request-shape restrictions.
- Require `POST` plus `application/json`.
- Keep strict body-size limits and add response-size limits for public HTTP.
- Reject batch requests until a reviewed batch policy exists.

4. Define an authentication path for trusted clients.
- If raw markdown or higher limits are needed remotely, that must use authenticated access, not the anonymous public endpoint.

### 5.6 Observability and Incident Response

The MCP endpoint must be observable as a security surface, not just as a feature surface.

Required changes:

1. Emit structured security telemetry for every request.
- Include tool name, normalized path, query hash, result count, rejected candidate count, sanitization flags, prompt-injection flags, client identity source, and rate-limit outcome.

2. Alert on suspicious patterns.
- Repeated non-doc path probes.
- High volumes of denied requests.
- Returned rows rejected for non-doc metadata.
- Prompt-injection flags above a defined threshold.

3. Preserve a security runbook.
- Incidents involving MCP abuse must have a documented disable path, logging location, and rollback path.

## 6) Required Test Gates

The MCP security posture is not considered implemented until these tests exist and pass:

1. Ingestion isolation tests
- Prove the MCP docs collection is built only from published docs pages.
- Prove `/blog`, `/ecosystem`, `/community`, `/search`, `/build`, and `/training` are excluded from the MCP docs collection.

2. Search boundary tests
- Prove `search_docs` cannot return non-doc routes even if the retrieval backend tries to hand them back.
- Prove returned results include trust and sanitization metadata.

3. Document retrieval tests
- Prove public HTTP `get_doc` never returns raw frontmatter, HTML comments, or source-only annotations.
- Prove non-doc path probes return generic not-found results.

4. Injection corpus tests
- Add prompt-injection and data-exfiltration probe cases to the MCP test suite.
- Include requests attempting to retrieve secrets, system prompts, DB schema details, and non-doc paths.

5. Transport tests
- Prove untrusted forwarded headers do not alter client identity when no trusted proxy is configured.
- Prove per-tool rate limits and request-size limits behave as specified.

## 7) Implementation Sequence

### Phase A - Immediate hardening

- Add production off-by-default gating for public MCP HTTP.
- Add trusted-proxy-aware client identity handling.
- Add generic-denial behavior for non-doc probes.
- Add security telemetry for denied and flagged requests.

### Phase B - Data isolation

- Build a true docs-only MCP retrieval collection.
- Move search to that collection exclusively.
- Add DB least-privilege enforcement for the MCP path.

### Phase C - Content-safe responses

- Replace public raw markdown with sanitized excerpts.
- Add trust labels and prompt-injection annotations.
- Add red-team regression tests for returned content.

### Phase D - Trusted-client access

- Add authenticated transport for clients that require raw markdown or higher quotas.
- Keep the anonymous endpoint on the reduced public-safe contract.

## 8) Definition of Done

This spec is complete only when:

1. The public MCP endpoint cannot retrieve non-doc data through search or direct fetch.
2. The public MCP endpoint no longer returns raw docs source markdown.
3. Prompt-injection indicators are annotated and logged.
4. The MCP retrieval corpus is provably docs-only.
5. The production HTTP endpoint is explicit, observable, and least-privilege by default.
