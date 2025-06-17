# lib/backend/player_state.ex
defmodule Backend.PlayerState do
  use GenServer

  @emojis ["👾", "🤖", "👻", "🐱", "🧑‍💻"]

  def start_link(_), do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    :ets.new(:players, [:named_table, :public, :set])
    {:ok, %{}}
  end

  def get_all_players do
    :ets.tab2list(:players)
    |> Enum.into(%{}, fn {id, %{x: x, y: y, emoji: emoji}} ->
      {id, %{x: x, y: y, emoji: emoji}}
    end)
  end

  # 初回 join 時と move 時の両方で使えるように arity を増やす
  def update_player(id, x, y, emoji) do
    :ets.insert(:players, {id, %{x: x, y: y, emoji: emoji}})
  end

  # ID から絵文字を決めるヘルパー
  def pick_emoji(id) do
    # ハッシュ値を使って決定的に選ぶ例
    idx = :erlang.phash2(id, length(@emojis))
    Enum.at(@emojis, idx)
  end
end
