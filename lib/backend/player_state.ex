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
    "avatar12.png",
    "avatar13.png",
    "avatar14.png",
    "avatar15.png",
    "avatar16.png",
    "avatar17.png",
    "avatar18.png",
    "avatar19.png",
    "avatar20.png",
    "avatar21.png",
    "avatar22.png"
  ]

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :ets.new(:players, [:named_table, :public, :set])
    {:ok, %{}}
  end

  def max_players do
    Application.get_env(:backend, :player_settings)[:max_players] || 10
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

  def count_players do
    :ets.info(:players, :size)
  end

  def find_free_position do
    taken_positions =
      get_all_players()
      |> Map.values()
      |> Enum.map(fn %{x: x, y: y} -> {x, y} end)

    # 👇 上の方だけを使う（例：Y座標は 50〜250）
    candidate_positions =
      for x <- 100..800//100,
          y <- 50..250//100,
          do: {x, y}

    Enum.find(candidate_positions, fn pos ->
      not Enum.member?(taken_positions, pos)
    end) || {100, 50} # fallback
  end

  def remove_player(id) do
    :ets.delete(:players, id)
  end
end
