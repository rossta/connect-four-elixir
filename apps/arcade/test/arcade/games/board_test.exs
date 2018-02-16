defmodule Arcade.Games.BoardTest do
  use ExUnit.Case, async: true
  require Logger

  alias ConnectFour.Board

  setup do
    %{board: Board.new()}
  end

  test "poison encoding", %{board: board} do
    json =
      board
      |> Board.drop_checker({1, :red})
      |> Poison.encode!()
      |> Poison.Parser.parse!()

    assert %{
             "cells" => %{"01" => %{"col" => 1, "color" => "red", "row" => 0}},
             "cols" => 7,
             "rows" => 6
           } == json
  end
end
