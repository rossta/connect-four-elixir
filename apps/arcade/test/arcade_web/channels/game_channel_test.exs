defmodule ArcadeWeb.GameChannelTest do
  use ArcadeWeb.ChannelCase

  alias ArcadeWeb.GameChannel

  setup do
    {:ok, game_server} = ConnectFour.Cache.start_server("game_id")
    {:ok, _, socket} =
      socket("player_socket:player_id", %{player_id: "player_1"})
      |> subscribe_and_join(GameChannel, "game:game_id")

    game = ConnectFour.fetch_game("game_id")

    on_exit fn ->
      GenServer.stop(game_server)
    end

    {:ok, socket: socket, game: game}
  end

  defp game_in_play(%{game: game} =context) do
    ConnectFour.join_game(game.id, "player_1", self())
    ConnectFour.join_game(game.id, "player_2", self())

    game = ConnectFour.fetch_game("game_id")

    %{context | game: ConnectFour.fetch_game(game.id)}
  end

  test "joined existing game", %{socket: socket, game: game} do
    ref = push socket, "game:joined"

    assert_broadcast "game:updated", ^game
    assert_reply ref, :ok, ^game
  end

  describe "game in play" do
    setup :game_in_play

    test "make successful game move", %{socket: socket, game: game} do
      ref = push socket, "game:move", %{"col" => 0}

      {:ok, updated_game} = ConnectFour.Game.move(game, "player_1", 0)

      assert_broadcast "game:updated", ^updated_game
      assert_reply ref, :ok, ^updated_game
    end

    test "make failed game move", %{socket: socket} do
      ref = push socket, "game:move", %{"col" => -1}

      assert_reply ref, :ok, %{foul: _}
    end
  end
end
