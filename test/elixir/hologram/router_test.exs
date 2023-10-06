defmodule Hologram.RouterTest do
  use Hologram.Test.BasicCase, async: false

  import Hologram.Router
  import Mox

  alias Hologram.Commons.ETS
  alias Hologram.Commons.Reflection
  alias Hologram.Router.PageResolver
  alias Hologram.Runtime.PageDigestRegistry
  alias Hologram.Test.Fixtures.Router.Module1

  defmodule PageDigestRegistryStub do
    @behaviour PageDigestRegistry

    def dump_path, do: "#{Reflection.tmp_path()}/#{__MODULE__}.plt"

    def ets_table_name, do: __MODULE__
  end

  defmodule PageResolverStub do
    @behaviour PageResolver

    def persistent_term_key, do: __MODULE__
  end

  setup :set_mox_global

  setup do
    stub_with(PageDigestRegistry.Mock, PageDigestRegistryStub)
    setup_page_digest_registry(PageDigestRegistryStub)

    stub_with(PageResolver.Mock, PageResolverStub)
    PageResolver.start_link([])

    :ok
  end

  describe "call/2" do
    test "request path is matched" do
      ETS.put(PageDigestRegistryStub.ets_table_name(), Module1, :dummy_module_1_digest)

      conn = Plug.Test.conn(:get, "/hologram-test-fixtures-router-module1")

      assert call(conn, []) == %{
               conn
               | halted: true,
                 resp_body: "page Hologram.Test.Fixtures.Router.Module1 template",
                 resp_headers: [
                   {"content-type", "text/html; charset=utf-8"},
                   {"cache-control", "max-age=0, private, must-revalidate"}
                 ],
                 state: :sent,
                 status: 200
             }
    end

    test "request path is not matched" do
      conn = Plug.Test.conn(:get, "/my-unmatched-request-path")

      assert call(conn, []) == %{
               conn
               | halted: false,
                 resp_body: nil,
                 resp_headers: [{"cache-control", "max-age=0, private, must-revalidate"}],
                 state: :unset,
                 status: nil
             }
    end
  end
end
