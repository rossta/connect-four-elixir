defmodule PlayFourWeb.GameChannel do
  use PlayFourWeb, :channel
  require Logger

  def join("game:" <> game_id, _payload, socket) do
    Logger.debug "Joining game channel #{game_id}", game_id: game_id

    player_id = socket.assigns.player_id

    with {:ok, game_server} <- ConnectFour.Cache.server(game_id) do
      game = case ConnectFour.Server.join(game_server, player_id, socket.channel_pid) do
        {:ok, game} ->
          Process.monitor(game_server)
          game
        {:fail, game} ->
          game
      end

      {:ok, game, assign(socket, :game_id, game_id)}
    else
      {:error, reason} ->
        Logger.debug "Error while joining game #{game_id}: #{reason}"
        {:error, %{reason: reason}}
    end
  end

  def handle_in("game:joined", _message, socket) do
    %{game_id: game_id} = socket.assigns

    with {:ok, game_server} <- ConnectFour.Cache.server(game_id),
         game <- ConnectFour.Server.game(game_server) do

      broadcast_from(socket, "game:updated", game)

      {:reply, {:ok, game}, socket}
    end
  end

  def handle_in("game:move", %{"col" => col}, socket) do
    %{player_id: player_id, game_id: game_id} = socket.assigns

    with {:ok, game_server} <- ConnectFour.Cache.server(game_id),
         {:ok, game} <- ConnectFour.Server.move(game_server, player_id, col) do

      broadcast!(socket, "game:updated", game)

      {:reply, {:ok, game}, socket}
    else
      {:foul, reason} ->
        {:reply, {:ok, %{foul: reason}}, socket}

      {:error, reason} ->
        {:stop, :shutdown, {:error, %{reason: reason}}, socket}

      other ->
        Logger.error "Unrecognized response game:move #{inspect other}"
        {:reply, {:ok, other}, socket}
    end
  end

  def handle_in("game:leave", _msg, socket) do
    %{game_id: game_id, player_id: player_id} = socket.assigns

    Logger.debug "Broadcasting player #{player_id} left game"

    {:ok, game_server} = ConnectFour.Cache.server(game_id)
    ConnectFour.Server.stop(game_server)
    {:noreply, socket}
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
  # defp authorized?(_payload) do
  #   true
  # end
end
