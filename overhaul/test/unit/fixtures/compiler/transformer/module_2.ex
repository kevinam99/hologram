defmodule Hologram.Test.Fixtures.Compiler.Transformer.Module2 do
  defmacro macro_2b(x, y) do
    quote do
      unquote(x) + unquote(y)
    end
  end
end
