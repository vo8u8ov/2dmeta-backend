# lib/backend_web/channels/room_channel.ex
defmodule BackendWeb.RoomChannel do
  use Phoenix.Channel
  alias Backend.PlayerState

 def join("room:lobby", _params, socket) do
    current_players = PlayerState.get_all_players() |> map_size()

    if current_players >= PlayerState.max_players() do
      {:error, %{reason: "room_full"}}  # ← 👈 ここが大事！
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

    {x, y} = PlayerState.find_free_position()
    PlayerState.update_player(id, x, y, avatar)

    players = PlayerState.get_all_players()
    push(socket, "me", %{id: id, avatar: avatar})
    push(socket, "sync_players", players)

    broadcast!(socket, "player_joined", %{id: id, x: x, y: y, avatar: avatar})
    {:noreply, socket}
  end

  def handle_in("move", %{"x" => x, "y" => y, "id" => id}, socket) do
    avatar = PlayerState.pick_avatar(id)
    PlayerState.update_player(id, x, y, avatar)
    broadcast!(socket, "move", %{x: x, y: y, id: id, avatar: avatar})
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    case Map.get(socket.assigns, :player_id) do
      nil ->
        IO.puts("[terminate] No player_id found, skipping cleanup")

      id ->
        IO.puts("[terminate] Cleaning up player: #{id}")
        PlayerState.remove_player(id)
    end

    :ok
  end
end
