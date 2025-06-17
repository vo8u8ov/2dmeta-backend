defmodule BackendWeb.RoomChannel do
  use Phoenix.Channel

  # クライアントが join したときの処理
  def join("room:lobby", _params, socket) do
    IO.puts("✅ User joined room:lobby")
    {:ok, socket}
  end

  # move イベントを受け取ったときの処理
  def handle_in("move", %{"id" => id, "x" => x, "y" => y}, socket) do
    IO.inspect({:move_received, id, x, y})
    broadcast!(socket, "move", %{"id" => id, "x" => x, "y" => y})
    {:noreply, socket}
  end
end
