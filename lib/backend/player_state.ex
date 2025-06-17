defmodule Backend.PlayerState do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :ets.new(:players, [:named_table, :public, :set])
    {:ok, %{}}
  end

  def get_all_players do
    :ets.tab2list(:players)
    |> Enum.into(%{}, fn {id, %{x: x, y: y}} -> {id, %{x: x, y: y}} end)
  end

  def update_player(id, x, y) do
    :ets.insert(:players, {id, %{x: x, y: y}})
  end
end
