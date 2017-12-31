defmodule ConnectFour.GameTest do
  use ExUnit.Case, async: true

  alias ConnectFour.{Game, Board}

  setup do
    %{game: %Game{status: :not_started}}
  end

  defp game_in_play(%{game: game}) do
    %{
      game:  %{ game |
        status: :in_play,
        red: "player_1",
        black: "player_2",
        next: :red,
      }
    }
  end

  test "move game not in play", %{game: game} do
    for status <- [:not_started, :over] do
      game = %{game | status: status}
      assert {:foul, "Game is not in play"} = Game.move(game, "player_id", 0)
    end
  end

  describe "game in play" do
    setup :game_in_play

    test "move out of turn", %{game: game} do
      assert {:foul, "Out of turn"} = Game.move(game, "player_2", 0)
    end

    test "move by nonplayer", %{game: game} do
      assert {:foul, "Player not playing"} = Game.move(game, "non_player", 0)
    end

    test "move invalid column", %{game: game} do
      assert {:foul, "Out of bounds"} = Game.move(game, "player_1", -1)
    end

    test "move red successful", %{game: game} do
      assert {:ok, %Game{}} = Game.move(game, "player_1", 0)
    end

    test "move black successful", %{game: game} do
      {:ok, game} = Game.move(game, "player_1", 0)
      assert {:ok, %Game{}} = Game.move(game, "player_2", 0)
    end
  end

  test "add_player to empty game", %{game: game} do
    assert game.status == :not_started

    %{red: red, black: black, status: status} = Game.add_player(game, "123")
    assert red == "123"
    assert black == nil
    assert status == :not_started
  end

  test "add_player to game with another player", %{game: game} do
    game = %{game | red: "123"}
    assert game.status == :not_started

    %{red: red, black: black, status: status} = Game.add_player(game, "abc")
    assert red == "123"
    assert black == "abc"
    assert status == :in_play
  end

  test "add_player to full game", %{game: game} do
    game = %{game | red: "123", black: "abc"}

    %{red: red, black: black} = Game.add_player(game, "xyz")

    assert red == "123"
    assert black == "abc"
  end

  test "which_player for full game", %{game: game} do
    game = %{game | red: "123", black: "abc"}
    assert :red == Game.which_player(game, "123")
    assert :black == Game.which_player(game, "abc")
  end

  test "which_player for game with one player", %{game: game} do
    game = %{game | red: "123"}
    assert :red == Game.which_player(game, "123")
    assert nil == Game.which_player(game, "abc")
  end

  test "which_player for empty game", %{game: game} do
    assert nil == Game.which_player(game, "123")
    assert nil == Game.which_player(game, "abc")
  end

  test "winner no moves", %{game: game} do
    assert Game.winner(game) == nil
  end

  test "winner four in column", %{game: game} do
    board = game.board
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})

    assert Game.winner(%{game | board: board}) == :black
  end

  test "add_winner adds winner, finishes game", %{game: game} do
    game = %{game | status: :in_play}
    board = game.board
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({2, :red})
    game = %{game | board: board}

    assert game.winner == nil
    assert game.status == :in_play

    game = game |> Game.add_winner

    assert game.winner == :red
    assert game.status == :over
  end

  test "add_winner no effect", %{game: game} do
    game = %{game | status: :in_play}
    assert game.winner == nil

    game = game |> Game.add_winner

    assert game.winner == nil
    assert game.status == :in_play
  end

  test "add_winner no in_play", %{game: game} do
    game = %{game | status: :in_play}
    board = game.board
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({2, :red})

    game = %{game | board: board, status: :not_started} |> Game.add_winner

    assert game.winner == nil

    game = %{game | status: :over} |> Game.add_winner

    assert game.winner == nil
  end
end
