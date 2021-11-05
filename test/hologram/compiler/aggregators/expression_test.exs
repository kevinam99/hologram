defmodule Hologram.Compiler.Aggregators.ExpressionTest do
  use Hologram.Test.UnitCase, async: true

  alias Hologram.Compiler.Aggregator
  alias Hologram.Compiler.IR.{ModuleDefinition, ModuleType, TupleType}
  alias Hologram.Template.VDOM.Expression
  alias Hologram.Test.Fixtures.PlaceholderModule1
  alias Hologram.Test.Fixtures.PlaceholderModule2

  test "aggregate/2" do
    vnode =
      %Expression{
        ir: %TupleType{
          data: [
            %ModuleType{module: PlaceholderModule1},
            %ModuleType{module: PlaceholderModule2}
          ]
        }
      }

    result = Aggregator.aggregate(vnode, %{})

    assert Map.keys(result) == [PlaceholderModule1, PlaceholderModule2]
    assert %ModuleDefinition{} = result[PlaceholderModule1]
    assert %ModuleDefinition{} = result[PlaceholderModule2]
  end
end
