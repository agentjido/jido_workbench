# External Agentic Framework Feature Landscape

Research date: 2026-02-20
GitHub stars snapshot: 2026-02-20 00:34:09 UTC

## Goal

Capture high-level features from leading agentic frameworks so we can build an internal Jido comparison matrix, now ranked by GitHub popularity.

## Active Comparison Set (ranked by GitHub stars)

1. AutoGen (Python, .NET)
2. LlamaIndex (Python, TypeScript)
3. CrewAI (Python)
4. Semantic Kernel (C#, Python, Java)
5. LangGraph (Python, TypeScript)
6. Haystack (Python)
7. Mastra (TypeScript)
8. Google ADK (Python, TypeScript, Go, Java)
9. PydanticAI (Python)
10. Pi Mono (TypeScript)
11. Sagents (Elixir)

### Dropped for this pass

- LangChain4j (Java): lower star count than the active set and overlaps with capabilities already covered by Semantic Kernel + AutoGen + LlamaIndex.

## GitHub Popularity Ranking

Method: star counts from canonical framework repositories via GitHub API.

| Rank | Framework | Repo | Stars | In Matrix |
|---|---|---|---:|---|
| 1 | AutoGen | `microsoft/autogen` | 54,654 | Yes |
| 2 | LlamaIndex | `run-llama/llama_index` | 47,071 | Yes |
| 3 | CrewAI | `crewAIInc/crewAI` | 44,319 | Yes |
| 4 | Semantic Kernel | `microsoft/semantic-kernel` | 27,261 | Yes |
| 5 | LangGraph | `langchain-ai/langgraph` | 24,848 | Yes |
| 6 | Haystack | `deepset-ai/haystack` | 24,240 | Yes |
| 7 | Mastra | `mastra-ai/mastra` | 21,218 | Yes |
| 8 | Google ADK | `google/adk-python` | 17,846 | Yes |
| 9 | PydanticAI | `pydantic/pydantic-ai` | 14,980 | Yes |
| 10 | Pi Mono | `badlogic/pi-mono` | 13,892 | Yes |
| 11 | LangChain4j | `langchain4j/langchain4j` | 10,784 | No |
| 12 | Sagents | `sagents-ai/sagents` | 103 | Yes (Elixir strategic benchmark) |

## Normalized Feature Taxonomy

Used to normalize naming differences across frameworks:

1. Multi-agent coordination patterns
2. Deterministic workflow control (sequential/parallel/branch/loop)
3. Durability and resume/recovery
4. Human-in-the-loop controls
5. State + memory model
6. Tooling and interoperability (including MCP where available)
7. Observability/tracing
8. Evals/testing support
9. Typed contracts/schema safety
10. Deployment/runtime operability

## High-Level Feature Matrix

Legend: `Y` = strong built-in support, `P` = partial/extension-based/early, `N` = not a core strength from current docs.

| Framework | Multi-agent | Workflow control | Durable/resume | HITL | State+memory | Tools/MCP | Observability | Evals | Typed/schema | Deployment/runtime |
|---|---|---|---|---|---|---|---|---|---|---|
| AutoGen | Y | Y | P | Y | Y | Y | Y | P | P | Y |
| LlamaIndex | Y | Y | P | Y | Y | P | Y | P | P | Y |
| CrewAI | Y | Y | Y | Y | Y | Y | Y | P | Y | Y |
| Semantic Kernel | Y | Y | P | P | Y | Y | Y | P | Y | Y |
| LangGraph | Y | Y | Y | Y | Y | P | Y | P | P | Y |
| Haystack | Y | Y | Y | P | Y | P | P | Y | P | Y |
| Mastra | Y | Y | Y | Y | Y | Y | Y | Y | P | Y |
| Google ADK | Y | Y | P | P | Y | Y | Y | Y | P | Y |
| PydanticAI | P | P | Y | Y | P | Y | Y | Y | Y | P |
| Pi Mono | P | P | P | P | Y | P | P | N | Y | P |
| Sagents | Y | P | Y | Y | Y | P | P | N | P | Y |

## Framework Feature Notes (High Level)

### AutoGen

- Split stack (Core + AgentChat + Extensions + Studio) from prototyping to distributed runtime.
- Core emphasizes actor-model, event-driven, async messaging, and distributed multi-agent execution.
- Includes HITL, state/session handling, and extension points for MCP/tools/code executors.

### LlamaIndex

- Agent model explicitly centered on LLM + tools + memory.
- Workflow abstraction provides event-driven, step-based orchestration with state and advanced control patterns.
- Strong observability integration ecosystem and growing workflow durability features.

### CrewAI

- Opinionated multi-agent model (`agents`, `crews`, `flows`) with a production-first stance.
- Event-driven flows with state management, branching/loops, and long-running execution behavior.
- Strong operational features: guardrails, human-input hooks, tracing ecosystem, enterprise trigger/deploy surfaces.

### Semantic Kernel

- Enterprise-oriented SDK stack with broad orchestration patterns (concurrent, sequential, handoff, group chat, magentic).
- Process framework and plugin model target business workflow modularity and controlled execution.
- Strong cross-language + observability posture (OpenTelemetry logs/metrics/traces).

### LangGraph

- Low-level orchestration runtime for long-running, stateful agents.
- Strong core primitives: durable execution, interrupts/HITL, memory, subgraphs, streaming.
- Production story tied to LangSmith for debugging/observability and deployment.

### Haystack

- Agent as a loop-based, tool-using component integrated into general pipeline graphs.
- Pipelines support branching + loops + async parallel execution for agentic and RAG-heavy designs.
- Distinctive debugging/recovery primitives via breakpoints, snapshots, and resume.

### Mastra

- TypeScript-native full-stack framework: agents, workflows, RAG, memory, MCP, evals.
- Workflow model supports explicit execution graphs, parallel/branch/loop, state persistence, and human review suspension.
- Strong practical ops posture: built-in observability + eval scoring and CI integration.

### Google ADK

- Multi-agent framework with deterministic workflow agents (sequential/parallel/loop) plus LLM-driven delegation patterns.
- Clear session/state/memory model and broad language support (Python/TS/Go/Java).
- Developer/ops strength via CLI + UI tooling, observability integrations, evaluation support, and MCP support.

### PydanticAI

- Type-focused Python framework with explicit emphasis on model/provider portability.
- Strong safety/ops mix: typed outputs, tool validation + retry patterns, OTel observability, eval framework.
- Notable for explicit durable execution integrations and built-in HITL tool approval flows.

### Pi Mono

- TypeScript monorepo centered on practical agent runtime + coding-agent UX (`pi-agent-core`, `pi-coding-agent`, `pi-ai`).
- Strong developer loop primitives: event streaming, session trees with branching, context compaction, SDK/RPC embedding.
- Highly extensible via custom tools, extension hooks, prompt/skill packages, and broad provider compatibility.

### Sagents (Elixir)

- Elixir/OTP-native agent framework aimed at interactive applications with supervised GenServer agents.
- Strong HITL and runtime UX primitives: approval interrupts, PubSub event streaming, LiveView-oriented patterns.
- Includes sub-agent delegation, middleware composition, virtual filesystem middleware, and state persistence hooks.

## Cross-Framework "Top Features" to Pull Into Jido Comparison

1. Deterministic + dynamic orchestration in one model
2. Durable runs with first-class resume/checkpoint/snapshot semantics
3. Native HITL approval/suspend points at tool and workflow boundaries
4. State scopes beyond a single run (session/user/app/temp semantics)
5. Unified tracing + metrics + token/cost visibility (OpenTelemetry-friendly)
6. Evals as a first-class loop (offline + CI + production feedback)
7. Typed contracts for tools and outputs with validation + retry behavior
8. Strong local developer loop (visual workflow/trace inspection + replay)
9. MCP and external tool interoperability as core, not bolt-on
10. Deployment surfaces that map cleanly from dev to production

## Sources

### GitHub repositories (stars + activity snapshot)

- https://github.com/microsoft/autogen
- https://github.com/run-llama/llama_index
- https://github.com/crewAIInc/crewAI
- https://github.com/microsoft/semantic-kernel
- https://github.com/langchain-ai/langgraph
- https://github.com/deepset-ai/haystack
- https://github.com/mastra-ai/mastra
- https://github.com/google/adk-python
- https://github.com/pydantic/pydantic-ai
- https://github.com/badlogic/pi-mono
- https://github.com/langchain4j/langchain4j
- https://github.com/sagents-ai/sagents

### Framework docs / feature references

#### AutoGen

- https://microsoft.github.io/autogen/stable/user-guide/core-user-guide/index.html
- https://microsoft.github.io/autogen/stable/user-guide/agentchat-user-guide/tutorial/index.html
- https://microsoft.github.io/autogen/dev/user-guide/extensions-user-guide/index.html

#### LlamaIndex

- https://docs.llamaindex.ai/en/stable/module_guides/deploying/agents/
- https://docs.llamaindex.ai/en/stable/module_guides/workflow/
- https://docs.llamaindex.ai/en/latest/module_guides/observability/

#### CrewAI

- https://docs.crewai.com/
- https://docs.crewai.com/en/concepts/flows
- https://docs.crewai.com/en/concepts/tasks

#### Semantic Kernel

- https://learn.microsoft.com/en-us/semantic-kernel/frameworks/agent/agent-orchestration/
- https://learn.microsoft.com/en-us/semantic-kernel/frameworks/process/process-framework
- https://learn.microsoft.com/en-us/semantic-kernel/concepts/enterprise-readiness/observability/
- https://learn.microsoft.com/en-us/semantic-kernel/get-started/supported-languages

#### LangGraph

- https://docs.langchain.com/oss/python/langgraph/overview
- https://docs.langchain.com/oss/javascript/langgraph/overview

#### Haystack

- https://docs.haystack.deepset.ai/docs/agent
- https://docs.haystack.deepset.ai/docs/pipelines
- https://docs.haystack.deepset.ai/docs/pipeline-breakpoints
- https://docs.haystack.deepset.ai/docs/asyncpipeline

#### Mastra

- https://mastra.ai/
- https://mastra.ai/workflows
- https://mastra.ai/observability
- https://mastra.ai/en/docs/evals/running-in-ci

#### Google ADK

- https://google.github.io/adk-docs/get-started/about/
- https://google.github.io/adk-docs/agents/workflow-agents/
- https://google.github.io/adk-docs/sessions/
- https://google.github.io/adk-docs/sessions/state/
- https://google.github.io/adk-docs/mcp/

#### PydanticAI

- https://ai.pydantic.dev/
- https://ai.pydantic.dev/tools-advanced/
- https://ai.pydantic.dev/agents/
- https://ai.pydantic.dev/durable_execution/temporal/
- https://ai.pydantic.dev/durable_execution/dbos/

#### Pi Mono

- https://github.com/badlogic/pi-mono
- https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/agent/README.md
- https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/README.md
- https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/ai/README.md

#### Sagents

- https://github.com/sagents-ai/sagents
- https://raw.githubusercontent.com/sagents-ai/sagents/main/README.md
