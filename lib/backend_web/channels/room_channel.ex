defmodule BackendWeb.RoomChannel do
  use Phoenix.Channel
  alias Backend.PlayerState

  def join("room:lobby", _params, socket) do
    if PlayerState.count_players() >= PlayerState.max_players() do
      {:error, %{reason: "room_full"}}
    else
      id = UUID.uuid4()
      socket = assign(socket, :player_id, id)
      send(self(), :after_join)
      {:ok, socket}
    end
  end

  def handle_info(:after_join, socket) do
    id = socket.assigns.player_id
    avatar = PlayerState.pick_avatar(id)
    PlayerState.update_player(id, 100, 100, avatar)

    players = PlayerState.get_all_players()
    push(socket, "me", %{id: id, avatar: avatar})
    push(socket, "sync_players", players)

    broadcast!(socket, "player_joined", %{id: id, x: 100, y: 100, avatar: avatar})

    {:noreply, socket}
  end

  def handle_in("move", %{"x" => x, "y" => y, "id" => id}, socket) do
    avatar = PlayerState.pick_avatar(id)
    PlayerState.update_player(id, x, y, avatar)
    broadcast!(socket, "move", %{x: x, y: y, id: id, avatar: avatar})
    {:noreply, socket}
  end

  def handle_in("say_hi", %{"id" => id}, socket) do
    broadcast!(socket, "say_hi", %{"id" => id})
    {:noreply, socket}
  end

  def handle_in("compliment", %{"id" => id, "message" => message}, socket) do
    broadcast!(socket, "compliment", %{"id" => id, "message" => message})
    {:noreply, socket}
  end

  def handle_in("hit", %{"id" => id}, socket) do
    broadcast!(socket, "hit", %{id: id})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case Map.get(socket.assigns, :player_id) do
      nil ->
        IO.puts("[terminate] No player_id found, skipping cleanup")
        :ok

      id ->
        IO.puts("[terminate] Cleaning up player: #{id}")
        PlayerState.remove_player(id)
        broadcast!(socket, "player_left", %{id: id})
        :ok
    end
  end
end
