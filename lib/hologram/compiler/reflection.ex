defmodule Hologram.Compiler.Reflection do
  alias Hologram.Compiler.IR.ModuleDefinition
  alias Hologram.Compiler.{Context, Helpers, Normalizer, Parser, Transformer}
  alias Hologram.Utils

  # TODO: refactor & test
  def app_name do
    Mix.Project.get().project[:app]
  end

  def app_path(config \\ get_config()) do
    case Keyword.get(config, :app_path) do
      nil -> "#{root_path()}/app"
      app_path -> app_path
    end
  end

  def ast(module_segs) when is_list(module_segs) do
    Helpers.module(module_segs)
    |> ast()
  end

  def ast(module) do
    source_path(module)
    |> Parser.parse_file!()
    |> Normalizer.normalize()
  end

  def get_config do
    Application.get_env(app_name(), :hologram)
  end

  # DEFER: optimize, e.g. load the manifest in config
  def get_page_digest(module) do
    File.cwd!() <> "/priv/static/hologram/manifest.json"
    |> File.read!()
    |> Jason.decode!()
    |> Map.get("#{module}")
  end

  def has_template?(module) do
    function_exported?(module, :template, 0)
  end

  # TODO: refactor & test
  def list_pages(opts \\ []) do
    glob = "#{pages_path()}/**/*.ex"
    regex = ~r/defmodule\s+([\w\.]+)\s+do\s+/

    Path.wildcard(glob)
    |> Enum.map(fn filepath ->
      code = File.read!(filepath)
      [_, module] = Regex.run(regex, code)
      String.to_atom("Elixir.#{module}")
    end)
  end

  # DEFER: instead of matching the macro on arity, pattern match the params as well
  def macro_definition(module, name, params) do
    arity = Enum.count(params)

    module_definition(module).macros
    |> Enum.filter(&(&1.name == name && &1.arity == arity))
    |> hd()
  end

  def module?(arg) do
    if Code.ensure_loaded?(arg) do
      to_string(arg)
      |> String.split(".")
      |> hd()
      |> Kernel.==("Elixir")
    else
      false
    end
  end

  @doc """
  Returns the corresponding module definition.

  ## Examples
      iex> Reflection.get_module_definition(Abc.Bcd)
      %ModuleDefinition{module: Abc.Bcd, ...}
  """
  @spec module_definition(module()) :: %ModuleDefinition{}

  def module_definition(module) do
    ast(module)
    |> Transformer.transform(%Context{})
  end

  def pages_path(config \\ get_config()) do
    case Keyword.get(config, :pages_path) do
      nil -> "#{app_path()}/pages"
      pages_path -> pages_path
    end
  end

  def root_path do
    File.cwd!()
  end

  def router_module(config \\ get_config()) do
    case Keyword.get(config, :router_module) do
      nil ->
        app_web_namespace =
          app_name()
          |> to_string()
          |> Utils.append("_web")
          |> Macro.camelize()
          |> String.to_atom()

        Helpers.module([app_web_namespace, :Router])

      router_module ->
        router_module
    end
  end

  def router_path do
    router_module() |> source_path()
  end

  @doc """
  Returns the file path of the given module's source code.

  ## Examples
      iex> Reflection.source_path(Hologram.Compiler.Reflection)
      "/Users/bart/Files/Projects/hologram/lib/hologram/compiler/reflection.ex"
  """
  @spec source_path(module()) :: String.t()

  def source_path(module) do
    module.module_info()[:compile][:source]
    |> to_string()
  end

  def standard_lib?(module) do
    source_path = source_path(module)
    root_path = root_path()
    app_path = app_path()

    !String.starts_with?(source_path, "#{app_path}/")
    && !String.starts_with?(source_path, "#{root_path}/lib/")
    && !String.starts_with?(source_path, "#{root_path}/test/")
    && !String.starts_with?(source_path, "#{root_path}/deps/")
  end

  def templatable?(module_def) do
    Helpers.is_component?(module_def)
    || Helpers.is_page?(module_def)
    || Helpers.is_layout?(module_def)
  end
end
