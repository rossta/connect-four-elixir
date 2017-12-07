defmodule ConnectFourWeb.GameChannel do
  use ConnectFourWeb, :channel

  alias ConnectFour.Games

  def join("game:" <> game_id, payload, socket) do
    if authorized?(payload) do
      player_id = socket.assigns.player_id

      with {:ok, game_server} <- Games.Cache.game_server(game_id),
           {:ok, _} <- Game.join(game_server, player_id, socket.channel_pid) do

        {:ok, assign(socket, :game_id, game_id)}

      else
        {:error, reason} ->
          {:error, %{reason: reason}}
      end

    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
