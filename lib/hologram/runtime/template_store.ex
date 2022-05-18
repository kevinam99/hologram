defmodule Hologram.Runtime.TemplateStore do
  require Logger
  use Hologram.Commons.MemoryStore
  alias Hologram.Compiler.Reflection

  @impl true
  def populate_table do
    Logger.debug("Hologram: template store load path = #{Reflection.release_template_store_path()}")

    Reflection.release_template_store_path()
    |> populate_table_from_file()
  end

  @impl true
  def table_name, do: :hologram_template_store
end
