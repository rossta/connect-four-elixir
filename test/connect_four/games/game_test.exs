defmodule ConnectFour.Games.GameTest do
  use ExUnit.Case, async: true

  alias ConnectFour.Games.Game

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
end
