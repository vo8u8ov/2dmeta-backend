# lib/backend/player_state.ex
defmodule Backend.PlayerState do
  use GenServer

  @avatars [
    "avatar1.png",
    "avatar2.png",
    "avatar3.png",
    "avatar4.png",
    "avatar5.png",
    "avatar6.png",
    "avatar7.png",
    "avatar8.png",
    "avatar9.png",
    "avatar10.png",
    "avatar11.png",
    "avatar12.png"
  ]

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :ets.new(:players, [:named_table, :public, :set])
    {:ok, %{}}
  end

  def get_all_players do
    :ets.tab2list(:players)
    |> Enum.into(%{}, fn {id, %{x: x, y: y, avatar: avatar}} ->
      {id, %{x: x, y: y, avatar: avatar}}
    end)
  end

  def update_player(id, x, y, avatar) do
    :ets.insert(:players, {id, %{x: x, y: y, avatar: avatar}})
  end

  def pick_avatar(id) do
    idx = :erlang.phash2(id, length(@avatars))
    Enum.at(@avatars, idx)
  end

  def remove_player(id) do
    :ets.delete(:players, id)
  end
end
