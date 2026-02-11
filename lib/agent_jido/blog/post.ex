defmodule AgentJido.Blog.Post do
  @moduledoc """
  Represents a blog post in the AgentJido site.

  Parsed at compile time from Markdown/LiveMarkdown files in `priv/blog/`.
  Frontmatter provides structured metadata; the body contains rendered HTML.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(description: "Unique slug derived from filename"),
              author: Zoi.string(description: "Post author"),
              title: Zoi.string(description: "Post title"),
              body: Zoi.string(description: "Rendered HTML body") |> Zoi.default(""),
              description: Zoi.string(description: "Short description") |> Zoi.default(""),
              tags: Zoi.any(description: "List of tag strings") |> Zoi.default([]),
              date: Zoi.any(description: "Publication date as Date struct"),
              path: Zoi.string(description: "App-relative source path") |> Zoi.default(""),
              source_path: Zoi.string(description: "Absolute source filename") |> Zoi.default(""),
              is_livebook: Zoi.boolean(description: "Whether this is a .livemd file") |> Zoi.default(false),
              post_type:
                Zoi.enum([:post, :announcement, :release, :tutorial, :case_study],
                  description: "Type of blog post"
                )
                |> Zoi.default(:post),
              audience:
                Zoi.enum([:general, :beginner, :intermediate, :advanced],
                  description: "Target audience level"
                )
                |> Zoi.default(:general),
              word_count: Zoi.integer(description: "Number of words in body") |> Zoi.default(0),
              reading_time_minutes: Zoi.integer(description: "Estimated reading time in minutes") |> Zoi.default(0),
              related_docs: Zoi.any(description: "List of related documentation paths") |> Zoi.default([]),
              related_posts: Zoi.any(description: "List of related post ids") |> Zoi.default([]),
              validation:
                Zoi.map(
                  %{
                    repos: Zoi.any(description: "List of ecosystem repo ids") |> Zoi.default([]),
                    source_modules: Zoi.any(description: "List of module name strings") |> Zoi.default([]),
                    source_files: Zoi.any(description: "List of repo-relative file paths") |> Zoi.default([]),
                    ecosystem_packages: Zoi.any(description: "List of ecosystem package ids") |> Zoi.default([]),
                    min_elixir_version: Zoi.string(description: "Minimum Elixir version") |> Zoi.optional(),
                    min_package_versions: Zoi.any(description: "List of %{package, version} maps") |> Zoi.default([]),
                    claims:
                      Zoi.any(description: "Explicit claims an agent should verify")
                      |> Zoi.default([]),
                    evergreen: Zoi.boolean(description: "Whether content is evergreen") |> Zoi.default(false)
                  },
                  description: "Source code validation metadata"
                )
                |> Zoi.default(%{}),
              freshness:
                Zoi.map(
                  %{
                    content_hash: Zoi.string(description: "SHA256 hash of filename + body") |> Zoi.default(""),
                    stale_after_days:
                      Zoi.integer(description: "Days before content is considered stale")
                      |> Zoi.default(365),
                    last_refreshed_at: Zoi.string(description: "ISO8601 datetime of last refresh") |> Zoi.optional(),
                    last_validated_at:
                      Zoi.string(description: "ISO8601 datetime of last validation")
                      |> Zoi.optional(),
                    validation_status:
                      Zoi.enum([:unknown, :valid, :invalid, :needs_review],
                        description: "Current validation status"
                      )
                      |> Zoi.default(:unknown),
                    validated_by: Zoi.string(description: "Who performed the validation") |> Zoi.optional(),
                    validation_notes: Zoi.string(description: "Notes from the validator") |> Zoi.optional()
                  },
                  description: "Content freshness tracking"
                )
                |> Zoi.default(%{}),
              seo:
                Zoi.map(
                  %{
                    canonical_url: Zoi.string(description: "Canonical URL for the post") |> Zoi.optional(),
                    og_title: Zoi.string(description: "Open Graph title") |> Zoi.optional(),
                    og_description: Zoi.string(description: "Open Graph description") |> Zoi.optional(),
                    og_image: Zoi.string(description: "Open Graph image URL") |> Zoi.optional(),
                    keywords: Zoi.any(description: "SEO keywords") |> Zoi.default([]),
                    noindex:
                      Zoi.boolean(description: "Whether to exclude from search indexes")
                      |> Zoi.default(false)
                  },
                  description: "SEO metadata"
                )
                |> Zoi.default(%{}),
              quality:
                Zoi.map(
                  %{
                    reviewed_by: Zoi.any(description: "List of reviewer identifiers") |> Zoi.default([]),
                    reviewed_at: Zoi.string(description: "ISO8601 datetime of last review") |> Zoi.optional(),
                    confidence: Zoi.number(description: "Confidence score 0.0-1.0") |> Zoi.default(0.5),
                    linted: Zoi.boolean(description: "Whether content has been linted") |> Zoi.default(false)
                  },
                  description: "Content quality tracking"
                )
                |> Zoi.default(%{}),
              livebook:
                Zoi.map(
                  %{
                    runnable:
                      Zoi.boolean(description: "Whether the livebook is runnable")
                      |> Zoi.default(false),
                    elixir_version: Zoi.string(description: "Required Elixir version") |> Zoi.optional(),
                    mix_deps: Zoi.any(description: "List of Mix dependency specs") |> Zoi.default([]),
                    required_env_vars:
                      Zoi.any(description: "List of required environment variables")
                      |> Zoi.default([]),
                    required_services:
                      Zoi.any(description: "List of required external services")
                      |> Zoi.default([]),
                    setup_instructions:
                      Zoi.string(description: "Setup instructions for running")
                      |> Zoi.optional()
                  },
                  description: "Livebook-specific metadata"
                )
                |> Zoi.default(%{})
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  def build(filename, attrs, body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    date = Date.from_iso8601!("#{year}-#{month}-#{day}")
    base_path = Application.app_dir(:agent_jido)
    path = String.replace(filename, base_path, "")

    is_livebook = String.ends_with?(filename, ".livemd")

    plain_text = body |> String.replace(~r/<[^>]+>/, " ") |> String.split(~r/\s+/, trim: true)
    word_count = length(plain_text)
    reading_time_minutes = max(1, div(word_count, 200))

    content_hash =
      :crypto.hash(:sha256, "#{filename}\n#{body}") |> Base.encode16(case: :lower)

    user_freshness = Map.get(attrs, :freshness, %{})

    freshness =
      Map.merge(user_freshness, %{content_hash: content_hash})

    attrs =
      attrs
      |> Map.put(:id, id)
      |> Map.put(:date, date)
      |> Map.put(:body, body)
      |> Map.put(:path, path)
      |> Map.put(:source_path, filename)
      |> Map.put(:is_livebook, is_livebook)
      |> Map.put(:word_count, word_count)
      |> Map.put(:reading_time_minutes, reading_time_minutes)
      |> Map.put(:freshness, freshness)

    case Zoi.parse(@schema, attrs) do
      {:ok, post} -> post
      {:error, errors} -> raise "Invalid blog post #{id}: #{inspect(errors)}"
    end
  end
end
