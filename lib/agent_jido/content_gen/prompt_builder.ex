defmodule AgentJido.ContentGen.PromptBuilder do
  @moduledoc """
  Builds generation prompts from content-plan metadata, templates, and source context.
  """

  @max_source_files 6
  @max_source_lines 120

  @spec build(struct(), map(), map()) :: String.t()
  def build(entry, target, opts) do
    brand_context = read_file("JIDO_BRAND_CONTEXT.md")
    docs_manifesto = read_file("specs/docs-manifesto.md")
    content_governance = read_file("specs/content-governance.md")
    template = template_for(entry, target)
    existing = Map.get(opts, :existing)
    update_mode = Map.get(opts, :update_mode, :improve)
    source_snippets = source_snippets(entry)

    """
    You are generating content for agentjido.xyz from a content-plan brief.

    Hard requirements:
    - Follow the brand/context rules exactly.
    - Respect docs-manifesto and content-governance constraints.
    - Use direct, technical tone (staff engineer to peer).
    - Avoid placeholders (TODO/TBD/coming soon/lorem ipsum).
    - Keep claims bounded and evidence-backed.
    - Include internal cross-links that resolve.
    - Mermaid diagrams are selective: only when the template or architecture section calls for it.

    OUTPUT CONTRACT:
    Return ONLY one JSON object with this shape:
    {
      "frontmatter": { ... },
      "body_markdown": "...",
      "citations": ["..."],
      "audit_notes": ["..."]
    }

    Constraints:
    - body_markdown must be plain markdown (no surrounding ``` fences)
    - frontmatter must include at minimum: title, description
    - preserve route intent for #{target.route}
    - when update_mode is improve, improve existing content instead of rewriting stylelessly

    === Entry metadata ===
    #{entry_metadata_json(entry)}

    === Target ===
    route: #{target.route}
    target_path: #{target.target_path}
    format: #{target.format}
    update_mode: #{update_mode}

    === Brand context ===
    #{brand_context}

    === Docs manifesto ===
    #{docs_manifesto}

    === Content governance ===
    #{content_governance}

    === Entry brief ===
    #{entry_brief(entry)}

    === Template guidance ===
    #{template}

    === Existing file content ===
    #{existing_content(existing)}

    === Source snippets ===
    #{render_source_snippets(source_snippets)}
    """
  end

  defp entry_metadata_json(entry) do
    entry_map =
      if is_struct(entry) do
        Map.from_struct(entry)
      else
        Map.new(entry)
      end

    entry_map
    |> Map.take([
      :id,
      :title,
      :section,
      :order,
      :status,
      :purpose,
      :audience,
      :content_type,
      :learning_outcomes,
      :repos,
      :source_modules,
      :source_files,
      :prerequisites,
      :related,
      :ecosystem_packages,
      :destination_route,
      :tags
    ])
    |> Jason.encode!(pretty: true)
  end

  defp template_for(entry, target) do
    path = template_path(entry, target)

    case path do
      nil -> "No template selected for this entry. Follow existing page structure and section conventions."
      template_path -> read_file(template_path)
    end
  end

  defp template_path(entry, target) do
    cond do
      entry.section == "build" -> "specs/templates/build-guide.md"
      entry.section == "training" -> "specs/templates/training-module.md"
      entry.section == "features" -> "specs/templates/feature-page.md"
      entry.section == "ecosystem" -> "specs/templates/ecosystem-package.md"
      entry.section == "docs" and String.starts_with?(target.route, "/docs/reference") -> "specs/templates/docs-reference.md"
      entry.section == "docs" -> "specs/templates/docs-concept.md"
      true -> nil
    end
  end

  defp entry_brief(entry) do
    case Map.get(entry, :body) do
      body when is_binary(body) and body != "" -> body
      _other -> "(no brief body provided)"
    end
  end

  defp existing_content(nil), do: "(none)"

  defp existing_content(%{raw: raw}) when is_binary(raw) do
    """
    Existing page content:
    ```markdown
    #{raw}
    ```
    """
  end

  defp existing_content(_other), do: "(none)"

  defp source_snippets(entry) do
    files =
      entry
      |> Map.get(:source_files, [])
      |> List.wrap()
      |> expand_files()
      |> Enum.uniq()
      |> Enum.take(@max_source_files)

    Enum.map(files, fn path ->
      %{
        path: path,
        snippet: file_snippet(path)
      }
    end)
  end

  defp expand_files(patterns) do
    root = File.cwd!()

    patterns
    |> Enum.flat_map(fn pattern ->
      abs_pattern = Path.expand(pattern, root)

      if String.contains?(pattern, "*") or String.contains?(pattern, "?") do
        Path.wildcard(abs_pattern)
      else
        [abs_pattern]
      end
    end)
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&Path.relative_to(&1, root))
  end

  defp file_snippet(path) do
    path
    |> File.stream!([], :line)
    |> Enum.take(@max_source_lines)
    |> Enum.join()
  rescue
    _ -> "# Unable to read source snippet"
  end

  defp render_source_snippets([]), do: "(no source snippets provided)"

  defp render_source_snippets(snippets) do
    snippets
    |> Enum.map(fn %{path: path, snippet: snippet} ->
      """
      File: #{path}
      ```text
      #{snippet}
      ```
      """
    end)
    |> Enum.join("\n")
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, contents} -> contents
      {:error, _} -> "(missing file: #{path})"
    end
  end
end
