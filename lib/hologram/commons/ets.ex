defmodule Hologram.Commons.ETS do
  @doc """
  Creates a named, public ETS table.
  """
  @spec create_named_table(atom) :: :ets.tid()
  def create_named_table(table_name) do
    :ets.new(table_name, [:named_table, :public])
    :ets.whereis(table_name)
  end

  @doc """
  Creates an unnamed, public ETS table.
  """
  @spec create_unnamed_table() :: :ets.tid()
  def create_unnamed_table do
    :ets.new(__MODULE__, [:public])
  end

  @doc """
  Returns the value stored in the ETS table under the given key.
  If the key doesn't exist the :error :atom is returned.
  """
  @spec get(:ets.tid(), any) :: {:ok, term} | :error
  def get(table_name_or_ref, key) do
    case :ets.lookup(table_name_or_ref, key) do
      [{^key, value}] ->
        {:ok, value}

      _fallback ->
        :error
    end
  end

  @doc """
  Puts an item into the ETS table.
  """
  @spec put(:ets.tid(), any, any) :: true
  def put(table_name_or_ref, key, value) do
    :ets.insert(table_name_or_ref, {key, value})
  end
end
