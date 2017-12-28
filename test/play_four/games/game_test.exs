defmodule PlayFour.Games.GameTest do
  use ExUnit.Case, async: true

  alias PlayFour.Games.{Game, Board}

  setup do
    %{game: %Game{status: :not_started}}
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

  test "poison encoding", %{game: game} do
    json = game
           |> Game.add_player("abc")
           |> Game.add_player("xyz")
           |> Poison.encode!
           |> Poison.Parser.parse!

    assert json["black"] == "xyz"
    assert json["red"] == "abc"
    assert json["board"] == %{"cells" => %{}, "cols" => 7, "rows" => 6}
    assert json["id"] == nil
    assert json["last"] == nil
    assert json["winner"] == nil
    assert json["turns"] == []
    assert json["status"] == "in_play"
    assert ["red", "black"] |> Enum.member?(json["next"])
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
