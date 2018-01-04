defmodule ConnectFour.WinnerTest do
  use ExUnit.Case, async: true

  alias ConnectFour.{Winner, Board}

  setup do
    %{board: Board.new}
  end

  test "winner no moves", %{board: board} do
    assert Winner.winner(board) == nil
  end

  test "winner four in column", %{board: board} do
    board = board
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({0, :black})

    assert Winner.winner(board) |> Winner.to_tuple() == {:black, [{0, 0}, {1, 0}, {2, 0}, {3, 0}]}
  end

  test "winner four in row", %{board: board} do
    board = board
            |> Board.drop_checker({0, :black})
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({2, :black})
            |> Board.drop_checker({3, :black})

    assert Winner.winner(board) |> Winner.to_tuple() == {:black, [{0, 3}, {0, 2}, {0, 1}, {0, 0}]}
  end

  test "winner four in row mid-row played last", %{board: board} do
    board = board
            |> Board.drop_checker({0, :red})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({2, :red})

    assert Winner.winner(board) |> Winner.to_tuple() == {:red, [{0, 3}, {0, 2}, {0, 1}, {0, 0}]}
  end

  test "winner less than four in a row right edge", %{board: board} do
    board = board
            |> Board.drop_checker({4, :red})
            |> Board.drop_checker({6, :red})
            |> Board.drop_checker({5, :red})

    assert Winner.winner(board) == nil
  end

  test "winner rising diagonal", %{board: board} do
    board = board
            |> Board.drop_checker({1, :red})   # 1
            |> Board.drop_checker({2, :black})
            |> Board.drop_checker({2, :red})   # 2
            |> Board.drop_checker({3, :black})
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({4, :black})
            |> Board.drop_checker({3, :red})   # 3
            |> Board.drop_checker({4, :black})
            |> Board.drop_checker({4, :red})
            |> Board.drop_checker({5, :black})
            |> Board.drop_checker({4, :red})   # 4

    assert Winner.winner(board) |> Winner.to_tuple() == {:red, [{3, 4}, {2, 3}, {1, 2}, {0, 1}]}
  end

  test "winner falling diagonal", %{board: board} do
    board = board
            |> Board.drop_checker({4, :black})   # 1
            |> Board.drop_checker({3, :red})
            |> Board.drop_checker({3, :black})   # 2
            |> Board.drop_checker({2, :red})
            |> Board.drop_checker({2, :black})
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({2, :black})   # 3
            |> Board.drop_checker({1, :red})
            |> Board.drop_checker({1, :black})
            |> Board.drop_checker({5, :red})
            |> Board.drop_checker({1, :black})   # 4

    assert Winner.winner(board) |> Winner.to_tuple() == {:black, [{0, 4}, {1, 3}, {2, 2}, {3, 1}]}
  end
end
