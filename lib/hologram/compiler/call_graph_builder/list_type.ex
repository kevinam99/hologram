# TODO: test

alias Hologram.Compiler.CallGraphBuilder
alias Hologram.Compiler.IR.ListType

defimpl CallGraphBuilder, for: ListType do
  def build(%{data: data}, module_defs, from_vertex) do
    CallGraphBuilder.build(data, module_defs, from_vertex)
  end
end
