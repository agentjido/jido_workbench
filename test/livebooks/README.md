# Livebook Drift Tests

Dedicated ExUnit tests for docs livebooks live under `test/livebooks/docs`.

## Run all livebook tests

```bash
mix test test/livebooks --only livebook
```

## Run one livebook test file

```bash
mix test test/livebooks/docs/weather_tool_response_livebook_test.exs
```

## External livebooks

Tests tagged with `:livebook_external` require environment configuration.
For the weather livebook, set one of:

- `OPENAI_API_KEY`
- `LB_OPENAI_API_KEY`

If neither env var is present, the test is skipped.

## Convention for new docs livebooks

For each new file in `priv/pages/docs/**/*.livemd`, add one matching
`*_livebook_test.exs` file under `test/livebooks/docs` with:

- `@moduletag :livebook`
- `use AgentJido.LivebookCase, livebook: "..."`
- one `"runs cleanly"` test using `run_livebook/0`
