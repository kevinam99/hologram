defmodule HologramFeatureTests.Helpers do
  alias Hologram.Router
  alias Wallaby.Browser

  def visit(session, page_module) do
    visit(session, page_module, [])
  end

  def visit(session, page_module, params) do
    path = Router.Helpers.page_path(page_module, params)
    Browser.visit(session, path)
  end

  @doc """
  Returns the given argument.
  It prevents compiler warnings in tests when the given value is not permitted is specific situation.
  """
  @spec wrap_value(any) :: any
  def wrap_value(value) do
    value
  end
end
