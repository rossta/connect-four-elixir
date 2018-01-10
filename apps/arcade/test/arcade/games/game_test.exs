defmodule Arcade.Games.GameTest do
  use ExUnit.Case, async: true

  alias ConnectFour.Game

  setup do
    %{game: %Game{status: :not_started}}
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
end
