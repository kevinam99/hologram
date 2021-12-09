alias Hologram.Compiler.{CallGraph, CallGraphBuilder}
alias Hologram.Compiler.IR.FunctionDefinition

defimpl CallGraphBuilder, for: FunctionDefinition do
  def build(%{module: module, name: name, body: body}, module_defs, _) do
    CallGraph.add_vertex({module, name})
    CallGraphBuilder.build(body, module_defs, {module, name})
  end
end
