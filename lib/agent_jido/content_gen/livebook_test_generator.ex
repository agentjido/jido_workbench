defmodule AgentJido.ContentGen.LivebookTestGenerator do
  @moduledoc """
  Generates deterministic per-page livebook tests for docs pages.
  """

  alias AgentJido.ContentGen

  @test_root Path.join(["test", "livebooks", "docs"])

  @spec ensure_test_file(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def ensure_test_file(livebook_path, route) when is_binary(livebook_path) and is_binary(route) do
    livebook_path = normalize_repo_relative(livebook_path)
    existing_path = find_existing_test_for_livebook(livebook_path)
    target_path = existing_path || deterministic_test_path(route)
    module_name = module_name_for_route(route)
    rendered = render_test(module_name, livebook_path)

    with :ok <- File.mkdir_p(Path.dirname(target_path)),
         :ok <- maybe_write(target_path, rendered) do
      {:ok, target_path}
    else
      {:error, reason} ->
        {:error, "failed to write livebook test file #{target_path}: #{inspect(reason)}"}
    end
  end

  @spec deterministic_test_path(String.t()) :: String.t()
  def deterministic_test_path(route) do
    slug =
      route
      |> doc_route_segments()
      |> Enum.join("_")

    Path.join(@test_root, "#{slug}_livebook_test.exs")
  end

  defp doc_route_segments(route) do
    segments =
      route
      |> ContentGen.normalize_route()
      |> String.trim_leading("/")
      |> String.split("/", trim: true)

    case segments do
      ["docs" | rest] when rest != [] -> rest
      ["docs"] -> ["index"]
      [] -> ["index"]
      _other -> ["index"]
    end
  end

  defp module_name_for_route(route) do
    suffix =
      route
      |> doc_route_segments()
      |> Enum.map_join("", &Macro.camelize/1)

    "AgentJido.Livebooks.Docs.#{suffix}LivebookTest"
  end

  defp render_test(module_name, livebook_path) do
    """
    defmodule #{module_name} do
      use AgentJido.LivebookCase,
        livebook: "#{livebook_path}",
        timeout: 60_000

      test "runs cleanly" do
        assert :ok = run_livebook()
      end
    end
    """
    |> String.trim_leading()
  end

  defp maybe_write(path, rendered) do
    case File.read(path) do
      {:ok, existing} when existing == rendered ->
        :ok

      {:ok, _existing} ->
        File.write(path, rendered)

      {:error, :enoent} ->
        File.write(path, rendered)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp find_existing_test_for_livebook(livebook_path) do
    escaped = Regex.escape(livebook_path)
    pattern = ~r/livebook:\s*"#{escaped}"/

    Path.wildcard(Path.join(@test_root, "**/*_livebook_test.exs"))
    |> Enum.sort()
    |> Enum.find(fn path ->
      case File.read(path) do
        {:ok, contents} -> Regex.match?(pattern, contents)
        _ -> false
      end
    end)
  end

  defp normalize_repo_relative(path) do
    expanded = Path.expand(path, File.cwd!())
    relative = Path.relative_to(expanded, File.cwd!())
    if String.starts_with?(relative, "../"), do: path, else: relative
  end
end
