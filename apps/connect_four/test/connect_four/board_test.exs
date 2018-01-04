defmodule ConnectFour.BoardTest do
  use ExUnit.Case, async: true
  require Logger

  alias ConnectFour.Board

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

    assert {:error, "Column full"} == Board.drop_checker(board, {1, :red})
  end

  test "drop_checker out-of-bounds", %{board: board} do
    assert {:error, "Out of bounds"} == Board.drop_checker(board, {-1, :red})
    assert {:error, "Out of bounds"} == Board.drop_checker(board, {7, :red})
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

  test "board load black:6:7:4433", %{board: board} do
    board = board
            |> Board.drop_checker({4, :black})
            |> Board.drop_checker({4, :red})
            |> Board.drop_checker({3, :black})
            |> Board.drop_checker({3, :red})

    assert Board.load("black-6:7-4:4:3:3") == board
  end
end
