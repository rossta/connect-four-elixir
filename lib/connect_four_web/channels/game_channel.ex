defmodule ConnectFourWeb.GameChannel do
  use ConnectFourWeb, :channel
  require Logger

  alias ConnectFour.Games

  def join("game:" <> game_id, payload, socket) do
    Logger.debug "Joining game channel #{game_id}", game_id: game_id

    if authorized?(payload) do
      player_id = socket.assigns.player_id

      with {:ok, game_server} <- Games.Cache.game_server(game_id),
           {:ok, _} <- Games.Server.join(game_server, player_id, socket.channel_pid) do
        Process.monitor(game_server)

        {:ok, assign(socket, :game_id, game_id)}
      else
        {:error, reason} ->

          Logger.debug "Failed to join game #{game_id}: #{reason}"
          {:error, %{reason: reason}}
      end

    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("game:joined", _message, socket) do
    player_id = socket.assigns.player_id
    game_id = socket.assigns.game_id

    Logger.debug "Broadcasting player joined #{game_id}"
    {:reply, :ok, socket}
  end

  def handle_in("game:status", _message, socket) do
    player_id = socket.assigns.player_id
    game_id = socket.assigns.game_id

    Logger.debug "Broadcasting player joined #{game_id}"

    case Games.Cache.game_server(game_id) do
      {:ok, game_server} ->
        reply = Games.Server.game(game_server, player_id)
        {:reply, {:ok, reply}, socket}

      {:error, reason} ->
        {:stop, :shutdown, {:error, %{reason: reason}}, socket}
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
