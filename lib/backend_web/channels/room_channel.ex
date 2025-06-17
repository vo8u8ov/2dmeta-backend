defmodule BackendWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _params, socket) do
    id = UUID.uuid4()
    socket = assign(socket, :player_id, id)

    send(self(), :after_join)
    {:ok, socket}
  end

  def handle_info(:after_join, socket) do
    id = socket.assigns.player_id

    # 全プレイヤー情報を取得（ETSなどで）
    players = Backend.PlayerState.get_all_players()

    push(socket, "me", %{id: id})
    push(socket, "sync_players", players)
    {:noreply, socket}
  end

  def handle_in("move", %{"x" => x, "y" => y, "id" => id}, socket) do
    Backend.PlayerState.update_player(id, x, y)
    broadcast!(socket, "move", %{x: x, y: y, id: id})
    {:noreply, socket}
  end
end
