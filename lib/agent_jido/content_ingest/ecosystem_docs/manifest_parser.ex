defmodule AgentJido.ContentIngest.EcosystemDocs.ManifestParser do
  @moduledoc """
  Parses ExDoc landing pages and sidebar manifests into crawlable page entries.
  """

  @sidebar_pattern ~r/src="(?<src>dist\/sidebar_items-[^"]+\.js)"/
  @meta_refresh_pattern ~r/<meta[^>]+http-equiv=["']refresh["'][^>]+content=["'][^"']*url=(?<target>[^"';]+)["']/i

  @typedoc "Normalized crawlable HexDocs page entry."
  @type page_entry :: %{
          page_kind: :module | :guide | :readme | :task,
          page_id: String.t(),
          page_title: String.t(),
          page_path: String.t(),
          crawl_url: String.t()
        }

  @spec follow_meta_refresh(String.t(), String.t()) :: String.t() | nil
  def follow_meta_refresh(html, base_url) when is_binary(html) and is_binary(base_url) do
    case Regex.named_captures(@meta_refresh_pattern, html) do
      %{"target" => target} -> absolute_url(base_url, target)
      _other -> nil
    end
  end

  def follow_meta_refresh(_html, _base_url), do: nil

  @spec sidebar_asset_url(String.t(), String.t()) :: String.t() | nil
  def sidebar_asset_url(html, base_url) when is_binary(html) and is_binary(base_url) do
    case Regex.named_captures(@sidebar_pattern, html) do
      %{"src" => src} -> absolute_url(base_url, src)
      _other -> nil
    end
  end

  def sidebar_asset_url(_html, _base_url), do: nil

  @spec parse_sidebar_items(String.t()) :: {:ok, map()} | {:error, term()}
  def parse_sidebar_items(script_body) when is_binary(script_body) do
    script_body
    |> String.trim()
    |> String.trim_leading("sidebarNodes=")
    |> String.trim_trailing(";")
    |> Jason.decode()
    |> case do
      {:ok, %{} = payload} -> {:ok, payload}
      {:ok, _other} -> {:error, :invalid_manifest}
      {:error, reason} -> {:error, {:invalid_manifest_json, reason}}
    end
  end

  def parse_sidebar_items(_script_body), do: {:error, :invalid_manifest}

  @spec page_entries(map(), String.t()) :: [page_entry()]
  def page_entries(%{} = manifest, docs_root_url) when is_binary(docs_root_url) do
    module_entries =
      manifest
      |> Map.get("modules", [])
      |> Enum.map(&build_module_entry(&1, docs_root_url))

    extra_entries =
      manifest
      |> Map.get("extras", [])
      |> Enum.map(&build_extra_entry(&1, docs_root_url))

    task_entries =
      manifest
      |> Map.get("tasks", [])
      |> Enum.map(&build_task_entry(&1, docs_root_url))

    (extra_entries ++ module_entries ++ task_entries)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq_by(&{&1.page_kind, &1.page_id})
  end

  def page_entries(_manifest, _docs_root_url), do: []

  @spec search_url(String.t()) :: String.t()
  def search_url(docs_root_url) when is_binary(docs_root_url) do
    absolute_url(docs_root_url, "search.html")
  end

  defp build_module_entry(%{"id" => id, "title" => title}, docs_root_url) do
    build_entry(:module, id, title, "#{id}.html", docs_root_url)
  end

  defp build_module_entry(_entry, _docs_root_url), do: nil

  defp build_task_entry(%{"id" => id, "title" => title}, docs_root_url) do
    build_entry(:task, id, title, "#{id}.html", docs_root_url)
  end

  defp build_task_entry(_entry, _docs_root_url), do: nil

  defp build_extra_entry(%{"id" => id, "title" => title}, docs_root_url) do
    kind =
      case id do
        "readme" -> :readme
        "overview" -> :readme
        "home" -> :readme
        _other -> :guide
      end

    build_entry(kind, id, title, "#{id}.html", docs_root_url)
  end

  defp build_extra_entry(_entry, _docs_root_url), do: nil

  defp build_entry(page_kind, page_id, page_title, page_path, docs_root_url)
       when is_atom(page_kind) and is_binary(page_id) and is_binary(page_title) and is_binary(page_path) do
    %{
      page_kind: page_kind,
      page_id: page_id,
      page_title: String.trim(page_title),
      page_path: page_path,
      crawl_url: absolute_url(docs_root_url, page_path)
    }
  end

  defp absolute_url(base_url, relative) do
    base = URI.parse(base_url)
    relative = String.trim(relative)

    case URI.parse(relative) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and is_binary(host) ->
        relative

      _other ->
        base
        |> URI.merge(relative)
        |> URI.to_string()
    end
  end
end
