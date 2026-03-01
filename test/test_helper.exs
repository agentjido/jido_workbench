include_livebook_tests? =
  System.get_env("INCLUDE_LIVEBOOK_TESTS") in ["1", "true", "TRUE", "yes", "YES"]

include_flaky_tests? =
  System.get_env("INCLUDE_FLAKY_TESTS") in ["1", "true", "TRUE", "yes", "YES"]

include_content_ops_tests? =
  System.get_env("INCLUDE_CONTENT_OPS_TESTS") in ["1", "true", "TRUE", "yes", "YES"]

exclude =
  [github_agent: true]
  |> then(fn tags ->
    if include_livebook_tests?, do: tags, else: Keyword.put(tags, :livebook, true)
  end)
  |> then(fn tags ->
    if include_flaky_tests?, do: tags, else: Keyword.put(tags, :flaky, true)
  end)
  |> then(fn tags ->
    if include_content_ops_tests?, do: tags, else: Keyword.put(tags, :content_ops, true)
  end)

ExUnit.start(exclude: exclude, capture_log: true)
