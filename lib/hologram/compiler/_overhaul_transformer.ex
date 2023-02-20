defmodule Hologram.Compiler.OverhaulTransformer do
  alias Hologram.Compiler.IR

  alias Hologram.Compiler.{
    ForExpressionTransformer,
    IfExpressionTransformer
  }

  alias Hologram.Compiler.IR

  # DEFINITIONS

  def transform({:defmacro, _, _}) do
    %IR.IgnoredExpression{type: :macro_definition}
  end

  # CONTROL FLOW

  def transform({:for, _, _} = ast) do
    ForExpressionTransformer.transform(ast)
  end

  def transform({:if, _, _} = ast) do
    IfExpressionTransformer.transform(ast)
  end
end
