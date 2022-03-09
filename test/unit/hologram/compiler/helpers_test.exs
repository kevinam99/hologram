defmodule Hologram.Compiler.HelpersTest do
  use Hologram.Test.UnitCase, async: true

  alias Hologram.Compiler.{Context, Helpers, Transformer}

  alias Hologram.Compiler.IR.{
    AtomType,
    Binding,
    FunctionDefinition,
    FunctionDefinitionVariants,
    IntegerType,
    MapAccess,
    ModuleDefinition,
    ParamAccess,
    UseDirective,
    Variable
  }

  test "aggregate_bindings_from_expression/1" do
    result =
      "%{a: x, b: y}"
      |> ast()
      |> Transformer.transform(%Context{})
      |> Helpers.aggregate_bindings_from_expression()

    expected = [
      x: [
        %MapAccess{
          key: %AtomType{value: :a}
        },
        %Variable{name: :x}
      ],
      y: [
        %MapAccess{
          key: %AtomType{value: :b}
        },
        %Variable{name: :y}
      ]
    ]

    assert result == expected
  end

  describe "aggregate_bindings_from_params/1" do
    test "no bindings" do
      # def test(1, 2) do
      # end

      params_ast = [1, 2]
      params = Helpers.transform_params(params_ast, %Context{})
      result = Helpers.aggregate_bindings_from_params(params)

      assert result == []
    end

    test "single binding in single param" do
      # def test(1, %{a: x}) do
      # end

      params_ast = [1, {:%{}, [line: 2], [a: {:x, [line: 2], nil}]}]
      params = Helpers.transform_params(params_ast, %Context{})
      result = Helpers.aggregate_bindings_from_params(params)

      expected = [
        %Binding{name: :x, access_path: [
          %ParamAccess{index: 1},
          %MapAccess{key: %AtomType{value: :a}}
        ]}
      ]

      assert result == expected
    end

    test "multiple bindings in single param" do
      # def test(1, %{a: x, b: y}) do
      # end

      params_ast = [1, {:%{}, [line: 2], [a: {:x, [line: 2], nil}, b: {:y, [line: 2], nil}]}]
      params = Helpers.transform_params(params_ast, %Context{})
      result = Helpers.aggregate_bindings_from_params(params)

      expected = [
        %Binding{name: :x, access_path: [
          %ParamAccess{index: 1},
          %MapAccess{key: %AtomType{value: :a}}
        ]},
        %Binding{name: :y, access_path: [
          %ParamAccess{index: 1},
          %MapAccess{key: %AtomType{value: :b}}
        ]}
      ]

      assert result == expected
    end

    test "multiple bindings in multiple params" do
      # def test(1, %{a: k, b: m}, 2, %{c: s, d: t}) do
      # end

      params_ast = [
        1,
        {:%{}, [line: 2], [a: {:k, [line: 2], nil}, b: {:m, [line: 2], nil}]},
        2,
        {:%{}, [line: 2], [c: {:s, [line: 2], nil}, d: {:t, [line: 2], nil}]}
      ]

      params = Helpers.transform_params(params_ast, %Context{})
      result = Helpers.aggregate_bindings_from_params(params)

      expected = [
        %Binding{name: :k, access_path: [
          %ParamAccess{index: 1},
          %MapAccess{key: %AtomType{value: :a}}
        ]},
        %Binding{name: :m, access_path: [
          %ParamAccess{index: 1},
          %MapAccess{key: %AtomType{value: :b}}
        ]},
        %Binding{name: :s, access_path: [
          %ParamAccess{index: 3},
          %MapAccess{key: %AtomType{value: :c}}
        ]},
        %Binding{name: :t, access_path: [
          %ParamAccess{index: 3},
          %MapAccess{key: %AtomType{value: :d}}
        ]}
      ]

      assert result == expected
    end

    test "sorting" do
      # def test(y, z) do
      # end

      params_ast = [{:y, [line: 2], nil}, {:x, [line: 2], nil}]
      params = Helpers.transform_params(params_ast, %Context{})
      result = Helpers.aggregate_bindings_from_params(params)

      expected = [
        %Binding{name: :x, access_path: [
          %ParamAccess{index: 1}
        ]},
        %Binding{name: :y, access_path: [
          %ParamAccess{index: 0}
        ]}
      ]

      assert result == expected
    end
  end

  describe "aggregate_function_def_variants/1" do
    test "single function with single variant" do
      function_defs = [
        %FunctionDefinition{
          bindings: [
            a: {0, [%Variable{name: :a}]}
          ],
          body: [
            %IntegerType{value: 1}
          ],
          name: :test,
          params: [
            %Variable{name: :a}
          ]
        }
      ]

      result = Helpers.aggregate_function_def_variants(function_defs)

      expected = %{test: %FunctionDefinitionVariants{name: :test, variants: function_defs}}

      assert result == expected
    end

    test "single function with multiple variants" do
      function_def_1 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]}
        ],
        body: [
          %IntegerType{value: 1}
        ],
        name: :test,
        params: [
          %Variable{name: :a}
        ]
      }

      function_def_2 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]},
          b: {1, [%Variable{name: :b}]}
        ],
        body: [
          %IntegerType{value: 2}
        ],
        name: :test,
        params: [
          %Variable{name: :a},
          %Variable{name: :b}
        ]
      }

      function_defs = [function_def_1, function_def_2]
      result = Helpers.aggregate_function_def_variants(function_defs)

      expected = %{test: %FunctionDefinitionVariants{name: :test, variants: function_defs}}

      assert result == expected
    end

    test "multiple functions with single variant" do
      function_def_1 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]}
        ],
        body: [
          %IntegerType{value: 1}
        ],
        name: :test_1,
        params: [
          %Variable{name: :a}
        ]
      }

      function_def_2 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]}
        ],
        body: [
          %IntegerType{value: 2}
        ],
        name: :test_2,
        params: [
          %Variable{name: :a}
        ]
      }

      function_defs = [function_def_1, function_def_2]
      result = Helpers.aggregate_function_def_variants(function_defs)

      expected = %{
        test_1: %FunctionDefinitionVariants{name: :test_1, variants: [function_def_1]},
        test_2: %FunctionDefinitionVariants{name: :test_2, variants: [function_def_2]}
      }

      assert result == expected
    end

    test "multiple functions with multiple variants" do
      function_def_1 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]}
        ],
        body: [
          %IntegerType{value: 1}
        ],
        name: :test_1,
        params: [
          %Variable{name: :a}
        ]
      }

      function_def_2 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]},
          b: {1, [%Variable{name: :b}]}
        ],
        body: [
          %IntegerType{value: 2}
        ],
        name: :test_1,
        params: [
          %Variable{name: :a},
          %Variable{name: :b}
        ]
      }

      function_def_3 = %FunctionDefinition{
        bindings: [
          a: {0, [%Variable{name: :a}]}
        ],
        body: [
          %IntegerType{value: 3}
        ],
        name: :test_2,
        params: [
          %Variable{name: :a}
        ]
      }

      function_defs = [function_def_1, function_def_2, function_def_3]
      result = Helpers.aggregate_function_def_variants(function_defs)

      expected = %{
        test_1: %FunctionDefinitionVariants{
          name: :test_1,
          variants: [function_def_1, function_def_2]
        },
        test_2: %FunctionDefinitionVariants{name: :test_2, variants: [function_def_3]}
      }

      assert result == expected
    end
  end

  test "class_name/1" do
    assert Helpers.class_name(Abc.Bcd) == "Elixir_Abc_Bcd"
  end

  test "get_components/1" do
    module_def_1 = %ModuleDefinition{
      module: Bcd.Cde,
      component?: true,
      uses: [
        %UseDirective{module: Hologram.Component}
      ]
    }

    module_def_2 = %ModuleDefinition{
      module: Def.Efg,
      component?: true,
      uses: [
        %UseDirective{module: Hologram.Component}
      ]
    }

    module_defs_map = %{
      Abc.Bcd => %ModuleDefinition{uses: []},
      Bcd.Cde => module_def_1,
      Cde.Def => %ModuleDefinition{uses: []},
      Def.Efg => module_def_2
    }

    result = Helpers.get_components(module_defs_map)
    expected = [module_def_1, module_def_2]

    assert result == expected
  end

  test "get_pages/1" do
    module_def_1 = %ModuleDefinition{
      module: Bcd.Cde,
      page?: true,
      uses: [
        %UseDirective{module: Hologram.Page}
      ]
    }

    module_def_2 = %ModuleDefinition{
      module: Def.Efg,
      page?: true,
      uses: [
        %UseDirective{module: Hologram.Page}
      ]
    }

    module_defs_map = %{
      Abc.Bcd => %ModuleDefinition{uses: []},
      Bcd.Cde => module_def_1,
      Cde.Def => %ModuleDefinition{uses: []},
      Def.Efg => module_def_2
    }

    result = Helpers.get_pages(module_defs_map)
    expected = [module_def_1, module_def_2]

    assert result == expected
  end

  test "module/1" do
    result = Helpers.module([:Hologram, :Compiler, :HelpersTest])
    expected = Elixir.Hologram.Compiler.HelpersTest
    assert result == expected
  end

  test "module_name/1" do
    assert Helpers.module_name(Abc.Bcd) == "Abc.Bcd"
  end

  describe "module_name_segments/1" do
    test "module" do
      assert Helpers.module_name_segments(Abc.Bcd) == [:Abc, :Bcd]
    end

    test "string" do
      assert Helpers.module_name_segments("Abc.Bcd") == [:Abc, :Bcd]
    end
  end

  describe "transform_params/2" do
    test "no params" do
      # def test do
      # end

      params = nil
      result = Helpers.transform_params(params, %Context{})

      assert result == []
    end

    test "vars" do
      # def test(a, b) do
      # end

      params = [{:a, [line: 1], nil}, {:b, [line: 1], nil}]
      result = Helpers.transform_params(params, %Context{})

      expected = [
        %Variable{name: :a},
        %Variable{name: :b}
      ]

      assert result == expected
    end

    test "primitive types" do
      # def test(:a, 2) do
      # end

      params = [:a, 2]
      result = Helpers.transform_params(params, %Context{})

      expected = [
        %AtomType{value: :a},
        %IntegerType{value: 2}
      ]

      assert result == expected
    end
  end

  describe "uses_module?/2" do
    @used_module Hologram.Commons.Parser

    test "true" do
      user_module = %ModuleDefinition{
        uses: [
          %UseDirective{
            module: @used_module
          }
        ]
      }

      assert Helpers.uses_module?(user_module, @used_module)
    end

    test "false" do
      user_module = %ModuleDefinition{uses: []}
      refute Helpers.uses_module?(user_module, @used_module)
    end
  end
end
