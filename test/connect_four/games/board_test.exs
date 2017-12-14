defmodule ConnectFour.Games.BoardTest do
  use ExUnit.Case, async: true
  require Logger

  alias ConnectFour.Games.Board

  setup do
    %{board: Board.new}
  end

  test "new sets defaults" do
    %{rows: rows, cols: cols, cells: cells} = Board.new

    assert rows == 6
    assert cols == 7
    assert cells == Map.new
  end

  test "drop_checker to board cells by color and column", %{board: board} do
    color = :red
    col = 4
    row = 0
    board = Board.drop_checker(board, {col, color})

    assert {row, col, color} == Board.checker(board, {row, col})
  end

  test "drop_checker twice", %{board: board} do
    board = Board.drop_checker(board, {1, :red})
    board = Board.drop_checker(board, {1, :black})

    assert {0, 1, :red} == Board.checker(board, {0, 1})
    assert {1, 1, :black} == Board.checker(board, {1, 1})
  end

  test "drop_checker in full column", %{board: board} do
    board = %{board | rows: 2}

    board = Board.drop_checker(board, {1, :red})
    board = Board.drop_checker(board, {1, :black})

    assert {:error, :full_column} == Board.drop_checker(board, {1, :red})
  end

  test "poison encoding", %{board: board} do
    board = Board.drop_checker(board, {1, :red})
    json = board |> Poison.encode! |> Poison.Parser.parse!

    assert %{"cells" => %{"01" => %{"col" => 1, "color" => "red", "row" => 0}},
      "cols" => 7, "rows" => 6} == json
  end
end
