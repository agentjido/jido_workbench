defmodule AgentJido.Analytics.Redactor do
  @moduledoc """
  Normalization and best-effort redaction helpers for analytics payloads.
  """

  @email_regex ~r/[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}/i
  @url_regex ~r/https?:\/\/[^\s]+/i
  @ipv4_regex ~r/\b\d{1,3}(?:\.\d{1,3}){3}\b/
  @phone_regex ~r/\+?\d(?:[\d\s().-]{7,}\d)/
  @long_number_regex ~r/\b\d{6,}\b/
  @whitespace_regex ~r/\s+/u

  @doc """
  Normalizes a query-like string into a canonical comparable form.
  """
  @spec normalize_query(term()) :: String.t()
  def normalize_query(value) when is_binary(value) do
    value
    |> String.trim()
    |> String.replace(@whitespace_regex, " ")
  end

  def normalize_query(value) when is_atom(value), do: value |> Atom.to_string() |> normalize_query()
  def normalize_query(value) when is_number(value), do: value |> to_string() |> normalize_query()
  def normalize_query(_value), do: ""

  @doc """
  Redacts sensitive patterns from query-like text while preserving intent keywords.
  """
  @spec redact_query(term()) :: String.t()
  def redact_query(value) do
    value
    |> normalize_query()
    |> redact_text()
  end

  @doc """
  Redacts sensitive patterns from arbitrary text payloads.
  """
  @spec redact_text(term()) :: String.t()
  def redact_text(value) do
    value
    |> normalize_query()
    |> String.replace(@url_regex, "[url]")
    |> String.replace(@email_regex, "[email]")
    |> String.replace(@ipv4_regex, "[ip]")
    |> String.replace(@phone_regex, "[phone]")
    |> String.replace(@long_number_regex, "[number]")
  end

  @doc """
  Stable SHA-256 hash of the normalized query string.
  """
  @spec query_hash(term()) :: String.t() | nil
  def query_hash(value) do
    normalized = normalize_query(value)

    if normalized == "" do
      nil
    else
      :crypto.hash(:sha256, normalized)
      |> Base.encode16(case: :lower)
    end
  end
end
