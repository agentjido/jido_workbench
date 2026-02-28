# Competitor Framework Briefings

This folder contains deep-dive competitor briefings for the top frameworks in our comparison set.
Each competitor now has a dedicated folder containing:

- `briefing.md`
- `topics.md`
- `homepage.png`
- `examples.md`
- `homepage-outline.md` (non-GitHub homepages)

Additional cross-competitor homepage guidance:
- `homepage-design-direction.md`
- `jido-homepage-benchmark.md`

Research snapshot date: 2026-02-20
GitHub stars snapshot: 2026-02-20 UTC

## Frameworks Covered (ranked by stars)

| Rank | Framework | Repo | Stars | Folder | Briefing | Topics | Screenshot | Examples | Homepage Outline |
|---|---|---|---:|---|---|---|---|---|---|
| 1 | AutoGen | `microsoft/autogen` | 54,654 | `01-autogen/` | `01-autogen/briefing.md` | `01-autogen/topics.md` | `01-autogen/homepage.png` | `01-autogen/examples.md` | `01-autogen/homepage-outline.md` |
| 2 | LlamaIndex | `run-llama/llama_index` | 47,071 | `02-llamaindex/` | `02-llamaindex/briefing.md` | `02-llamaindex/topics.md` | `02-llamaindex/homepage.png` | `02-llamaindex/examples.md` | `02-llamaindex/homepage-outline.md` |
| 3 | CrewAI | `crewAIInc/crewAI` | 44,319 | `03-crewai/` | `03-crewai/briefing.md` | `03-crewai/topics.md` | `03-crewai/homepage.png` | `03-crewai/examples.md` | `03-crewai/homepage-outline.md` |
| 4 | Semantic Kernel | `microsoft/semantic-kernel` | 27,261 | `04-semantic-kernel/` | `04-semantic-kernel/briefing.md` | `04-semantic-kernel/topics.md` | `04-semantic-kernel/homepage.png` | `04-semantic-kernel/examples.md` | `04-semantic-kernel/homepage-outline.md` |
| 5 | LangGraph | `langchain-ai/langgraph` | 24,848 | `05-langgraph/` | `05-langgraph/briefing.md` | `05-langgraph/topics.md` | `05-langgraph/homepage.png` | `05-langgraph/examples.md` | `05-langgraph/homepage-outline.md` |
| 6 | Haystack | `deepset-ai/haystack` | 24,240 | `06-haystack/` | `06-haystack/briefing.md` | `06-haystack/topics.md` | `06-haystack/homepage.png` | `06-haystack/examples.md` | `06-haystack/homepage-outline.md` |
| 7 | Mastra | `mastra-ai/mastra` | 21,218 | `07-mastra/` | `07-mastra/briefing.md` | `07-mastra/topics.md` | `07-mastra/homepage.png` | `07-mastra/examples.md` | `07-mastra/homepage-outline.md` |
| 8 | Google ADK | `google/adk-python` | 17,846 | `08-google-adk/` | `08-google-adk/briefing.md` | `08-google-adk/topics.md` | `08-google-adk/homepage.png` | `08-google-adk/examples.md` | `08-google-adk/homepage-outline.md` |
| 9 | PydanticAI | `pydantic/pydantic-ai` | 14,980 | `09-pydanticai/` | `09-pydanticai/briefing.md` | `09-pydanticai/topics.md` | `09-pydanticai/homepage.png` | `09-pydanticai/examples.md` | `09-pydanticai/homepage-outline.md` |
| 10 | Pi Mono | `badlogic/pi-mono` | 13,892 | `10-pi-mono/` | `10-pi-mono/briefing.md` | `10-pi-mono/topics.md` | `10-pi-mono/homepage.png` | `10-pi-mono/examples.md` | excluded (GitHub-only homepage) |
| 11 | Sagents (Elixir benchmark) | `sagents-ai/sagents` | 103 | `11-sagents/` | `11-sagents/briefing.md` | `11-sagents/topics.md` | `11-sagents/homepage.png` | `11-sagents/examples.md` | excluded (GitHub-only homepage) |

## Structure Used in Each Briefing

Each briefing follows the same layout so we can map directly into a comparison matrix:

1. Executive briefing
2. Ecosystem surface (core packages, runtimes, products)
3. Detailed feature list
4. Operational profile (observability, evals, deploy/runtime)
5. Strengths and risks
6. Jido implications
7. Primary sources

## Notes

- Source preference: official docs + official repos (primary sources only).
- Feature claims are scoped to what is documented publicly in the linked sources.
- Star rank is only one adoption signal; ecosystem depth and ops maturity are captured in each briefing.
