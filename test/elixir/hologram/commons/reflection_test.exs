defmodule Hologram.Commons.ReflectionTest do
  use Hologram.Test.BasicCase, async: true
  import Hologram.Commons.Reflection

  alias Hologram.Test.Fixtures.Commons.Reflection.Module1
  alias Hologram.Test.Fixtures.Commons.Reflection.Module2
  alias Hologram.Test.Fixtures.Commons.Reflection.Module3
  alias Hologram.Test.Fixtures.Commons.Reflection.Module4

  describe "alias?/1" do
    test "atom which is an alias" do
      assert alias?(Calendar.ISO)
    end

    test "atom which is not an alias" do
      refute alias?(:abc)
    end

    test "non-atom" do
      refute alias?(123)
    end
  end

  test "build_dir/0" do
    assert build_dir() == "#{File.cwd!()}/_build/test/lib/hologram/priv"
  end

  describe "component?" do
    test "is a component module" do
      assert component?(Module3)
    end

    test "is not a module" do
      refute component?(123)
    end

    test "is not a component module" do
      refute component?(__MODULE__)
    end
  end

  describe "elixir_module?/1" do
    test "existing Elixir module" do
      assert elixir_module?(Calendar.ISO)
    end

    test "atom that starts with an uppercase letter and is an alias of a non existing Elixir module" do
      refute elixir_module?(Aaa.Bbb)
    end

    test "atom that starts with an uppercase letter and is not an Elixir alias" do
      refute elixir_module?(:MyModule)
    end

    test "existing Erlang module" do
      refute elixir_module?(:maps)
    end

    test "atom that starts with a lowercase letter and is not an existing Erlang module" do
      refute elixir_module?(:my_module)
    end

    test "non-atom" do
      refute elixir_module?(123)
    end
  end

  describe "erlang_module?" do
    test "existing Elixir module" do
      refute erlang_module?(Calendar.ISO)
    end

    test "atom that starts with an uppercase letter and is an alias of a non existing Elixir module" do
      refute erlang_module?(Aaa.Bbb)
    end

    test "atom that starts with an uppercase letter and is not an Elixir alias" do
      refute erlang_module?(:MyModule)
    end

    test "existing Erlang module" do
      assert erlang_module?(:maps)
    end

    test "atom that starts with a lowercase letter and is not an existing Erlang module" do
      refute erlang_module?(:my_module)
    end

    test "non-atom" do
      refute erlang_module?(123)
    end
  end

  describe "has_function?/3" do
    test "returns true if the module has a function with the given name and arity" do
      assert has_function?(Module4, :test_fun, 2)
    end

    test "returns false if the module doesn't have a function with the given name and arity" do
      refute has_function?(Module4, :test_fun, 3)
    end
  end

  test "list_all_otp_apps/0" do
    assert Enum.sort(list_all_otp_apps()) == Enum.sort(list_all_otp_apps())
  end

  test "list_elixir_modules/0" do
    result = list_elixir_modules()

    assert Calendar.ISO in result
    assert Hologram.Template.Tokenizer in result
    assert Mix.Tasks.Holo.Test.CheckFileNames in result
    assert Sobelow.CI in result
    assert Mix.Tasks.Sobelow in result

    refute :elixir_map in result
    refute :dialyzer in result

    refute Enumerable.Atom in result
    refute Kernel.SpecialForms in result
  end

  test "list_elixir_modules/1" do
    result = list_elixir_modules([:elixir, :hologram])

    assert Calendar.ISO in result
    assert Hologram.Template.Tokenizer in result
    assert Mix.Tasks.Holo.Test.CheckFileNames in result
    refute Sobelow.CI in result
    refute Mix.Tasks.Sobelow in result

    refute :elixir_map in result
    refute :dialyzer in result

    refute Enumerable.Atom in result
    refute Kernel.SpecialForms in result
  end

  test "list_loaded_otp_apps/0" do
    result = list_loaded_otp_apps()

    assert :crypto in result
    assert :elixir in result
    assert :file_system in result
    assert :hologram in result
  end

  test "list_pages/0" do
    result = list_pages()

    assert Hologram.Test.Fixtures.Compiler.Module5 in result
    assert Hologram.Test.Fixtures.Compiler.CallGraph.Module11 in result
    assert Hologram.Test.Fixtures.Commons.Reflection.Module2 in result
    assert Hologram.Test.Fixtures.Page.Module1 in result

    refute Hologram.Test.Fixtures.Compiler.Module6 in result
    refute Hologram.Test.Fixtures.Compiler.CallGraph.Module4 in result
    refute Hologram.Compiler.Context in result
  end

  test "list_protocol_implementations" do
    result = list_protocol_implementations(String.Chars)

    assert String.Chars.Atom in result
    assert String.Chars.Hologram.Test.Fixtures.Commons.Reflection.Module5 in result
  end

  test "list_std_lib_elixir_modules/0" do
    result = list_std_lib_elixir_modules()

    assert Calendar.ISO in result
    assert DateTime in result
    assert Kernel in result

    refute :application in result
    refute :elixir in result
    refute :kernel in result

    refute Graph in result
    refute Hologram.Page in result

    refute Enumerable.Atom in result
    refute Kernel.SpecialForms in result
  end

  describe "module_beam_defs/1" do
    test "with debug info present in the BEAM file" do
      assert module_beam_defs(Module1) == [
               {{:fun_2, 2}, :def, [line: 7, column: 7],
                [
                  {[line: 7, column: 7],
                   [
                     {:a, [version: 0, line: 7, column: 13], nil},
                     {:b, [version: 1, line: 7, column: 16], nil}
                   ], [],
                   {{:., [line: 8, column: 7], [:erlang, :+]}, [line: 8, column: 7],
                    [
                      {:a, [version: 0, line: 8, column: 5], nil},
                      {:b, [version: 1, line: 8, column: 9], nil}
                    ]}}
                ]},
               {{:fun_1, 0}, :def, [line: 3, column: 7],
                [{[line: 3, column: 7], [], [], :value_1}]}
             ]
    end

    test "with debug info not present in the BEAM file" do
      assert module_beam_defs(Elixir.Hex) == []
    end

    test "with BEAM file not existing" do
      assert_raise Hologram.TemplateSyntaxError,
                   "BEAM file doesn't exist for module: Elixir.MyInvalidModule",
                   fn ->
                     module_beam_defs(MyInvalidModule)
                   end
    end
  end

  describe "module?/1" do
    test "existing Elixir module" do
      assert module?(Calendar.ISO)
    end

    test "atom that starts with an uppercase letter and is an alias of a non existing Elixir module" do
      refute module?(Aaa.Bbb)
    end

    test "atom that starts with an uppercase letter and is not an Elixir alias" do
      refute module?(:MyModule)
    end

    test "existing Erlang module" do
      assert module?(:maps)
    end

    test "atom that starts with a lowercase letter and is not an existing Erlang module" do
      refute module?(:my_module)
    end

    test "non-atom" do
      refute module?(123)
    end
  end

  test "module_name/1" do
    assert module_name(Aaa.Bbb) == "Aaa.Bbb"
  end

  test "otp_app/0" do
    assert otp_app() == :hologram
  end

  describe "page?" do
    test "is a page module" do
      assert page?(Module2)
    end

    test "is not a module" do
      refute page?(123)
    end

    test "is not a page module" do
      refute page?(__MODULE__)
    end
  end

  test "page_digest_plt_dump_file_name/0" do
    assert page_digest_plt_dump_file_name() == "page_digest.plt"
  end

  test "release_priv_dir/0" do
    assert release_priv_dir() == File.cwd!() <> "/_build/test/lib/hologram/priv"
  end

  test "release_static_dir/0" do
    assert release_static_dir() == File.cwd!() <> "/_build/test/lib/hologram/priv/static"
  end

  describe "protocol?/1" do
    test "module which is a protocol" do
      assert protocol?(String.Chars)
    end

    test "module which is not a protocol" do
      refute protocol?(Calendar.ISO)
    end

    test "non-module" do
      refute protocol?(123)
    end
  end

  test "root_dir/0" do
    assert root_dir() == File.cwd!()
  end

  test "root_priv_dir/0" do
    assert root_priv_dir() == File.cwd!() <> "/priv/hologram"
  end

  test "source_path/1" do
    assert source_path(__MODULE__) == __ENV__.file
  end

  test "tmp_dir/0" do
    assert tmp_dir() == File.cwd!() <> "/tmp"
  end
end
