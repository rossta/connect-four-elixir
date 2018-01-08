defmodule Joshua.MinimaxTest do
  use ExUnit.Case, async: true
  doctest Joshua

  require Logger

  alias Joshua.Minimax
  alias ConnectFour.Board

  setup do
    %{board: nil}
  end

  defp board_one_move(context) do
    %{context | board: Board.load("black-6:7-0")}
  end

  test "minimax empty board" do
    board = Board.load("black-6:7")

    assert {{0, 3, :red}, _score} = Minimax.minimax(board, 1)
  end

  describe "1 move" do
    setup :board_one_move

    test "minimax board depth 1", %{board: board} do
      assert {{0, 3, :red}, _score} = Minimax.minimax(board, 1)
    end

    test "minimax board depth 3", %{board: board} do
      assert {{0, 3, :red}, _score} = Minimax.minimax(board, 3)
    end

    # Take too long to run
    # test "evaluate board depth 5", %{board: board} do
    #   assert {{0, 3, :red}, _score} = Minimax.minimax(board, 5)
    # end
  end
end
