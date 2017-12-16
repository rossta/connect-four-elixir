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

  test "drop_checker multiple", %{board: board} do
    board = board
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({2, :red})

    assert {0, 0, :black} == Board.checker(board, {0, 0})
    assert {0, 1, :red} == Board.checker(board, {0, 1})
    assert {1, 1, :black} == Board.checker(board, {1, 1})
    assert {0, 2, :red} == Board.checker(board, {0, 2})
  end

  test "drop_checker in full column", %{board: board} do
    board = %{board | rows: 2}

    board = board
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({1, :black})

    assert {:error, :full_column} == Board.drop_checker(board, {1, :red})
  end

  test "checker for occupied cell", %{board: board} do
    board = board |> Board.drop_checker({1, :red})

    assert {0, 1, :red} == Board.checker(board, {0, 1})
  end

  test "checker for unoccupied cell in bounds", %{board: board} do
    assert {0, 2, :empty} == Board.checker(board, {0, 2})
  end

  test "checker for cell out-of-bounds", %{board: board} do
    assert nil == Board.checker(board, {-1, 0})
    assert nil == Board.checker(board, {0, -1})
    assert nil == Board.checker(board, {6, 0})
    assert nil == Board.checker(board, {0, 7})
  end

  test "poison encoding", %{board: board} do
    json = board
           |> Board.drop_checker({1, :red})
           |> Poison.encode!
           |> Poison.Parser.parse!

    assert %{"cells" => %{"01" => %{"col" => 1, "color" => "red", "row" => 0}},
      "cols" => 7, "rows" => 6} == json
  end
end
