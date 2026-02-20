defmodule AgentJido.LivebookCase do
  @moduledoc """
  Shared ExUnit setup for livebook drift tests.

  Usage:

      use AgentJido.LivebookCase,
        livebook: "priv/pages/docs/getting-started.livemd",
        timeout: 60_000

  Optional external env gating:

      use AgentJido.LivebookCase,
        livebook: "priv/pages/docs/cookbook/weather-tool-response.livemd",
        timeout: 120_000,
        external: true,
        required_any_env: ["OPENAI_API_KEY", "LB_OPENAI_API_KEY"]
  """

  @default_timeout 60_000

  @doc false
  @spec normalize_env_value(String.t() | nil) :: String.t() | nil
  def normalize_env_value(nil), do: nil
  def normalize_env_value(""), do: nil
  def normalize_env_value(value), do: value

  defmacro __using__(opts) do
    livebook = Keyword.fetch!(opts, :livebook)
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    external = Keyword.get(opts, :external, false)
    required_any_env = Keyword.get(opts, :required_any_env, [])
    livebook_path = Path.expand(livebook, File.cwd!())

    quote bind_quoted: [
            livebook_path: livebook_path,
            timeout: timeout,
            external: external,
            required_any_env: required_any_env
          ] do
      use ExUnit.Case, async: false

      alias AgentJido.TestSupport.LivebookRunner

      @moduletag :livebook
      if external, do: @moduletag(:livebook_external)

      @livebook_path livebook_path
      @livebook_timeout timeout
      @livebook_required_any_env required_any_env

      setup do
        if @livebook_required_any_env == [] or any_required_env_present?(@livebook_required_any_env) do
          :ok
        else
          :skip
        end
      end

      defp run_livebook(opts \\ []) do
        timeout = Keyword.get(opts, :timeout, @livebook_timeout)
        LivebookRunner.run_file(@livebook_path, timeout: timeout)
      end

      defp any_required_env_present?(vars) do
        Enum.any?(vars, fn var ->
          var
          |> System.get_env()
          |> AgentJido.LivebookCase.normalize_env_value()
          |> is_binary()
        end)
      end

      @doc false
      def livebook_path, do: @livebook_path
    end
  end
end
