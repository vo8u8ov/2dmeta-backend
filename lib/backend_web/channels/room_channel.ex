# lib/backend_web/channels/room_channel.ex
defmodule BackendWeb.RoomChannel do
  use Phoenix.Channel
  alias Backend.PlayerState

  def join("room:lobby", _params, socket) do
    id = UUID.uuid4()
    socket = assign(socket, :player_id, id)
    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    id = socket.assigns.player_id
    # 新規プレイヤーには初期座標＋絵文字を付与して保存
    emoji = PlayerState.pick_emoji(id)
    PlayerState.update_player(id, 100, 100, emoji)

    # 全員分の状態を pull
    players = PlayerState.get_all_players()
    # 自分にも emoji を渡す
    push(socket, "me", %{id: id, emoji: emoji})
    push(socket, "sync_players", players)
    {:noreply, socket}
  end

  def handle_in("move", %{"x" => x, "y" => y, "id" => id}, socket) do
    # 移動時には既に選ばれた絵文字を保持して再保存
    emoji = PlayerState.pick_emoji(id)
    PlayerState.update_player(id, x, y, emoji)
    broadcast!(socket, "move", %{x: x, y: y, id: id, emoji: emoji})
    {:noreply, socket}
  end
end
