defmodule ArcadeWeb.GameChannel do
  use ArcadeWeb, :channel
  require Logger

  alias ConnectFour.Game

  def join("game:" <> game_id, _payload, socket) do
    Logger.debug("Joining game channel #{game_id}", game_id: game_id)

    player_id = socket.assigns.player_id

    # ConnectFour.join(game_id)
    with {_, %Game{} = game} <- ConnectFour.join_game(game_id, player_id, socket.channel_pid) do
      {:ok, game, assign(socket, :game_id, game_id)}
    else
      {:error, reason} ->
        Logger.debug("Error while joining game #{game_id}: #{reason}")
        {:error, %{reason: reason}}
    end
  end

  # ConnectFour.game(game_id)
  def handle_in("game:joined", _message, socket) do
    %{game_id: game_id} = socket.assigns

    game = ConnectFour.fetch_game(game_id)

    broadcast_from(socket, "game:updated", game)

    {:reply, {:ok, game}, socket}
  end

  # ConnectFour.move(game_id)
  def handle_in("game:move", %{"col" => col}, socket) do
    %{player_id: player_id, game_id: game_id} = socket.assigns

    with {:ok, game} <- ConnectFour.move(game_id, player_id, col) do
      broadcast!(socket, "game:updated", game)

      {:reply, {:ok, game}, socket}
    else
      {:foul, reason} ->
        {:reply, {:ok, %{foul: reason}}, socket}

      {:error, reason} ->
        {:stop, :shutdown, {:error, %{reason: reason}}, socket}

      other ->
        Logger.error("Unrecognized response game:move #{inspect(other)}")
        {:reply, {:ok, other}, socket}
    end
  end

  def handle_in("game:bot", socket) do
    %{game_id: game_id} = socket.assigns

    game = ConnectFour.fetch_game(game_id)
    player_id = game.black

    col = 0

    {:ok, game} = ConnectFour.move(game_id, player_id, col)
    broadcast!(socket, "game:updated", game)

    {:reply, {:ok, game}, socket}
  end

  # # ConnectFour.stop(game_id)
  # def handle_in("game:leave", _msg, socket) do
  #   %{game_id: game_id, player_id: player_id} = socket.assigns
  #
  #   Logger.debug "Broadcasting player #{player_id} left game"
  #
  #   ConnectFour.Client.stop_server(game_id)
  #   {:noreply, socket}
  # end
  #
  # # Channels can be used in a request/response fashion
  # # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end
end
