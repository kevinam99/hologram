defmodule Hologram.Test.Fixtures.Template.Renderer.Module21 do
  use Hologram.Page

  route "/hologram-test-fixtures-template-renderer-module21"

  param :key_1
  param :key_2

  layout Hologram.Test.Fixtures.LayoutFixture

  @impl Page
  def init(_params, client, _server) do
    put_state(client, key_2: "state_value_2", key_3: "state_value_3")
  end

  @impl Page
  def template do
    ~H"page vars = {vars |> :maps.to_list() |> :lists.sort() |> inspect()}"
  end
end
