alias Hologram.Compiler.{Helpers, Serializer}
alias Hologram.Runtime.{PageDigestStore, TemplateStore}
alias Hologram.Template.Renderer
alias Hologram.Utils

defimpl Renderer, for: Atom do
  def render(page_module, conn, _bindings, _slots) do
    context = init_context(page_module)

    layout_module = page_module.layout()
    layout_template = TemplateStore.get!(layout_module)
    layout_state = layout_module.init(conn)
    layout_bindings = layout_state |> put_context(context)

    page_template = TemplateStore.get!(page_module)
    page_state = page_module.init(conn.params, conn)
    page_bindings = page_state |> put_context(context)
    slots = {page_bindings, default: page_template}

    {html, initial_state} = Renderer.render(layout_template, conn, layout_bindings, slots)

    initial_state =
      initial_state
      |> Map.put(:layout, layout_state)
      |> Map.put(:page, page_state)

    serialized_state = Serializer.serialize(initial_state)

    """
    <!DOCTYPE html>
    #{html}\
    """
    |> String.replace("###SERIALIZED_STATE###", serialized_state)
  end

  defp init_context(page_module) do
    context =
      %{
        __class__: Helpers.class_name(page_module),
        __digest__: PageDigestStore.get!(page_module)
      }

    serialized_context = Serializer.serialize(context)

    Map.put(context, :__serialized_context__, serialized_context)
  end

  defp put_context(bindings, context) do
    Map.put(bindings, :__context__, context)
  end
end
