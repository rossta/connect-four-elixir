defmodule Joshua.MinimaxTest do
  use ExUnit.Case, async: true
  doctest Joshua

  require Logger

  alias Joshua.Minimax
  alias ConnectFour.Board

  setup do
    %{board: nil}
  end

  test "evaluate empty board" do
    board = Board.load("black-6:7")

    assert Minimax.evaluate(board, :black) == 0
  end

  defp board_one_move(context) do
    %{context | board: Board.load("black-6:7-0")}
  end

  describe "1 move" do
    setup :board_one_move

    test "evaluate board", %{board: board} do
      assert Minimax.evaluate((board |> Board.drop_checker({0, :red})), :red) == 1
      assert Minimax.evaluate((board |> Board.drop_checker({1, :red})), :red) == 1
      assert Minimax.evaluate((board |> Board.drop_checker({2, :red})), :red) == 2
      assert Minimax.evaluate((board |> Board.drop_checker({3, :red})), :red) == 4
      assert Minimax.evaluate((board |> Board.drop_checker({4, :red})), :red) == 2
      assert Minimax.evaluate((board |> Board.drop_checker({5, :red})), :red) == 1
      assert Minimax.evaluate((board |> Board.drop_checker({6, :red})), :red) == 0
    end

    test "evaluate board depth 1", %{board: board} do
      assert {{0, 3, :red}, _score} = Minimax.minimax(board, 1)
    end

    test "evaluate board depth 3", %{board: board} do
      assert {{0, 3, :red}, _score} = Minimax.minimax(board, 3)
    end

    # Take too long to run
    # test "evaluate board depth 5", %{board: board} do
    #   assert {{0, 3, :red}, _score} = Minimax.minimax(board, 5)
    # end
  end
end
