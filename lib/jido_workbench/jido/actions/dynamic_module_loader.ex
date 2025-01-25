defmodule JidoWorkbench.Actions.DynamicModuleLoader do
  require Logger

  use Jido.Action,
    name: "dynamic_module_loader",
    description: "Dynamically create and load an Elixir module using Igniter SDK",
    schema: [
      module_name: [type: :string, required: true, doc: "Name of the module to create"],
      module_code: [type: :string, required: true, doc: "The module code to compile"],
      location_type: [
        type: :string,
        required: false,
        doc: "Location type (:source_folder, :test, :test_support)",
        default: "source_folder"
      ]
    ]

  def test do
    # Example usage
    module_code = """
    defmodule Demo.DynamicGreeter do
      def hello(name) do
        "Hello, \#{name}!"
      end
    end
    """

    params = %{
      module_name: "Demo.DynamicGreeter",
      module_code: module_code,
      location_type: "source_folder"
    }

    # Call through your agent
    {:ok, result} = JidoWorkbench.Actions.DynamicModuleLoader.run(params, %{})
  end

  def run(params, _context) do
    Logger.metadata(action: "dynamic_module_loader")

    module_name = Igniter.Project.Module.parse(params.module_name)
    location_type = String.to_existing_atom(params.location_type)

    # {:ok, igniter} <- Igniter.start_link(),
    with igniter <- Igniter.new(),
         {:ok, updated_igniter} <-
           create_module(igniter, module_name, params.module_code, location_type),
         # Ensure it's compiled and loaded
         :ok <- ensure_module_loaded(module_name) do
      {:ok,
       %{
         result: %{
           module: module_name,
           location_type: location_type
         }
       }}
    else
      {:error, reason} = error ->
        Logger.error("Failed to load dynamic module: #{inspect(reason)}")
        error
    end
  end

  defp create_module(igniter, module_name, contents, location_type) do
    Logger.debug("Creating module: #{inspect(module_name)} at #{location_type}")

    try do
      updated_igniter =
        Igniter.Project.Module.create_module(
          igniter,
          module_name,
          contents,
          location: location_type
        )

      {:ok, updated_igniter}
    rescue
      e ->
        Logger.error("Failed to create module: #{inspect(e)}")
        {:error, :creation_failed}
    end
  end

  defp ensure_module_loaded(module_name) do
    Logger.debug("Ensuring module is loaded: #{inspect(module_name)}")

    try do
      # Attempt to load the module
      if Code.ensure_loaded?(module_name) do
        :ok
      else
        {:error, :module_not_loaded}
      end
    rescue
      e ->
        Logger.error("Failed to load module: #{inspect(e)}")
        {:error, :load_failed}
    end
  end

  # Helper to find and update existing modules
  defp update_existing_module(igniter, module_name, contents) do
    Logger.debug("Attempting to update existing module: #{inspect(module_name)}")

    updater = fn zipper ->
      {:ok, Sourceror.Zipper.replace(zipper, Sourceror.parse_string!(contents))}
    end

    case Igniter.Project.Module.find_and_update_module(igniter, module_name, updater) do
      {:ok, updated_igniter} -> {:ok, updated_igniter}
      {:error, _} = error -> error
    end
  end
end
