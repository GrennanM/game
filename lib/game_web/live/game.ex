defmodule GameWeb.GameView do
  use Phoenix.LiveView

  alias Game.Game

  @key_mapper %{
    "ArrowUp" => :up,
    "ArrowDown" => :down,
    "ArrowLeft" => :left,
    "ArrowRight" => :right
  }

  def mount(_params, _session, socket) do
    {:ok, assign(socket, game: Game.new())}
  end

  def handle_event("move", %{"key" => key}, socket) do
    with {:ok, direction} <- Map.fetch(@key_mapper, key),
         {:ok, game = %Game{}} <- Game.do_move(socket.assigns.game, direction) do
      {:noreply, assign(socket, game: game)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "new_game",
        %{"board_size" => board_size, "obstacle_count" => obstacle_count},
        socket
      ) do
    size = String.to_integer(board_size)
    obstacle_count = String.to_integer(obstacle_count)

    {:noreply, assign(socket, game: Game.new(size, obstacle_count))}
  end
end
