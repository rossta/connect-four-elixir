defmodule ConnectFourWeb.LobbyChannel do
  use ConnectFourWeb, :channel

  require Logger

  def join("lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
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
  # broadcast to everyone in the current topic (lobby:lobby).
  def handle_in("new_game", payload, socket) do
    # broadcast socket, "new_game", payload
    Logger.info "LobbyChannel.handle_in new_game not implemented"
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
