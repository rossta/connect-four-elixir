defmodule ConnectFour.Games.GameTest do
  use ExUnit.Case, async: true

  alias ConnectFour.Games.{Game, Board}

  setup do
    %{game: %Game{}}
  end

  test "add_player to empty game", %{game: game} do
    %{red: red, black: black} = Game.add_player(game, "123")
    assert red == "123"
    assert black == nil
  end

  test "add_player to game with another player", %{game: game} do
    game = %{game | red: "123"}
    %{red: red, black: black} = Game.add_player(game, "abc")
    assert red == "123"
    assert black == "abc"
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
    game = game |> Game.add_player("abc") |> Game.add_player("xyz")
    json = game |> Poison.encode! |> Poison.Parser.parse!

    assert %{
      "black" => "xyz",
      "red" => "abc",
      "board" => %{"cells" => %{}, "cols" => 7, "rows" => 6},
      "id" => nil,
      "last" => nil,
      "turns" => [],
      "winner" => nil,
      "status" => "not_started"
    } == json
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

  test "winner four in row", %{game: game} do
    board = game.board
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({2, :black})
            |> Board.drop_checker({3, :black})

    assert Game.winner(%{game | board: board}) == :black
  end

  test "winner four in row mid-row played last", %{game: game} do
    board = game.board
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({2, :red})

    assert Game.winner(%{game | board: board}) == :red
  end

  test "winner less than four in a row right edge", %{game: game} do
    board = game.board
            |> Board.drop_checker({4, :red})
            |> Board.drop_checker({6, :red})
            |> Board.drop_checker({5, :red})

    assert Game.winner(%{game | board: board}) == nil
  end

  test "winner rising diagonal", %{game: game} do
    board = game.board
            |> Board.drop_checker({0, :red})   # 1
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({1, :red})   # 2
            |> Board.drop_checker({2, :black})
            |> Board.drop_checker({2, :red})
            |> Board.drop_checker({3, :black})
            |> Board.drop_checker({2, :red})   # 3
            |> Board.drop_checker({3, :black})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({4, :black})
            |> Board.drop_checker({3, :red})   # 4

    assert Game.winner(%{game | board: board}) == :red
  end

  test "winner falling diagonal", %{game: game} do
    board = game.board
            |> Board.drop_checker({3, :black})   # 1
            |> Board.drop_checker({2, :red})
            |> Board.drop_checker({2, :black})   # 2
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({1, :black})   # 3
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({4, :red})
            |> Board.drop_checker({0, :black})   # 4

    assert Game.winner(%{game | board: board}) == :black
  end
end
