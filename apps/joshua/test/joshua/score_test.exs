defmodule Joshua.ScoreTest do
  use ExUnit.Case, async: true

  alias Joshua.Score
  alias ConnectFour.Board

  test "evaluate empty board" do
    board = Board.load("black-6:7")

    assert Score.evaluate(board, :black) == 0
  end

  test "max is equal to sum of all row, col, and diag segments" do
    segments_count = Score.max(Board.new())
    all_row_segments = 24
    all_col_segments = 21
    all_diag_segments = 24

    assert all_row_segments + all_col_segments + all_diag_segments == segments_count
  end

  test "evaluate_segment empty" do
    assert [:empty, :empty, :empty, :empty] |> Score.evaluate_segment(:red) == 0
  end

  test "evaluate_segment some friendlies" do
    assert [:red, :empty, :empty, :empty] |> Score.evaluate_segment(:red) == 1
    assert [:red, :red, :empty, :empty] |> Score.evaluate_segment(:red) == 20
    assert [:red, :red, :red, :empty] |> Score.evaluate_segment(:red) == 300
    assert [:red, :red, :red, :red] |> Score.evaluate_segment(:red) == 4000
  end

  test "evaluate segment some enemies" do
    assert [:black, :empty, :empty, :empty] |> Score.evaluate_segment(:red) == -1
    assert [:black, :black, :empty, :empty] |> Score.evaluate_segment(:red) == -20
    assert [:black, :black, :black, :empty] |> Score.evaluate_segment(:red) == -300
    assert [:black, :black, :black, :black] |> Score.evaluate_segment(:red) == -4000
  end

  test "evaluate segment block move" do
    assert [:black, :red, :empty, :empty] |> Score.evaluate_segment(:red) == 0
  end

  test "evaluate board 1 move" do
    board = Board.load("black-6:7-0")

    assert Score.evaluate((board |> Board.drop_checker({0, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({1, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({2, :red})), :red) == 2
    assert Score.evaluate((board |> Board.drop_checker({3, :red})), :red) == 4
    assert Score.evaluate((board |> Board.drop_checker({4, :red})), :red) == 2
    assert Score.evaluate((board |> Board.drop_checker({5, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({6, :red})), :red) == 0
  end

  test "evaluate board winning move" do
    board = Board.load("black-6:7-0")

    assert Score.evaluate((board |> Board.drop_checker({0, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({1, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({2, :red})), :red) == 2
    assert Score.evaluate((board |> Board.drop_checker({3, :red})), :red) == 4
    assert Score.evaluate((board |> Board.drop_checker({4, :red})), :red) == 2
    assert Score.evaluate((board |> Board.drop_checker({5, :red})), :red) == 1
    assert Score.evaluate((board |> Board.drop_checker({6, :red})), :red) == 0
  end
end
