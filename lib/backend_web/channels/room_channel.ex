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
    avatar = PlayerState.pick_avatar(id)
    PlayerState.update_player(id, 100, 100, avatar)

    players = PlayerState.get_all_players()
    push(socket, "me", %{id: id, avatar: avatar})
    push(socket, "sync_players", players)

    # 🟢 新しい参加者を他のクライアントにも通知
    broadcast!(socket, "player_joined", %{id: id, x: 100, y: 100, avatar: avatar})

    {:noreply, socket}
  end

  def handle_in("move", %{"x" => x, "y" => y, "id" => id}, socket) do
    avatar = PlayerState.pick_avatar(id)
    PlayerState.update_player(id, x, y, avatar)
    broadcast!(socket, "move", %{x: x, y: y, id: id, avatar: avatar})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
  id = socket.assigns.player_id
  PlayerState.remove_player(id)

  # 🟥 他のプレイヤーに通知
  broadcast!(socket, "player_left", %{id: id})
  :ok
end
end
