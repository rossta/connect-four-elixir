defmodule ConnectFour.Games.Game do
  @derive [Poison.Encoder]
  alias ConnectFour.Games.{Game, Board}
  require Logger

  @type state :: :not_started | :in_play | :over

  defstruct [
    id: nil,
    red: nil,
    black: nil,
    last: nil,
    turns: [],
    status: :not_started,
    winner: nil,
    board: Board.new
  ]

  def move(%{board: board, turns: turns} = game, player_id, {_col, _color} = turn) do
    board = board |> Board.drop_checker(turn)
    game = %{game | board: board, last: player_id, turns: [turn | turns]}
    game = game |> add_winner

    {:ok, game}
  end

  def move(%{last: player_id}, player_id, _column), do: {:foul, "Not player's turn"}
  def move(%{red: player_id} = game, player_id, column), do: move(game, player_id, {column, :red})
  def move(%{black: player_id} = game, player_id, column), do: move(game, player_id, {column, :black})
  def move(%{black: _black, red: _red}, _player_id, _column), do: {:foul, "Player not playing"}

  def add_player(%Game{red: nil} = game, player_id), do: (%{game | red: player_id} |> start_game)
  def add_player(%Game{black: nil} = game, player_id), do: (%{game | black: player_id} |> start_game)
  def add_player(%Game{} = game, _player_id), do: game

  def start_game(%Game{red: nil} = game), do: game
  def start_game(%Game{black: nil} = game), do: game
  def start_game(%Game{status: :not_started} = game), do: %{game | status: :in_play}
  def start_game(%Game{} = game), do: game

  def which_player(%Game{red: player_id}, player_id), do: :red
  def which_player(%Game{black: player_id}, player_id), do: :black
  def which_player(%Game{}, _player_id), do: nil

  def add_winner(%{status: status} = game) when status != :in_play, do: game
  def add_winner(game) do
    game |> determine_winner(game |> winner)
  end

  defp determine_winner(game, nil), do: game
  defp determine_winner(game, winner), do: (%{game | winner: winner } |> end_game)
  defp end_game(%{winner: winner, status: :in_play} = game) when not is_nil(winner) do
    %{game | status: :over }
  end
  defp end_game(game), do: game

  def winner(%Game{board: board}), do: winner(board)
  def winner(%Board{last: nil}), do: nil
  def winner(%Board{last: last} = board) do
    column_winner(board, last) || row_winner(board, last) || diagonal_winner(board, last)
  end

  defp column_winner(_board, {row, _col, _color}) when row + 1 < 4, do: nil
  defp column_winner(_board, {_row, _col, :empty}), do: nil
  defp column_winner(board, {_row, _col, color} = checker) do
    column_winner(board, checker, color, 1)
  end
  defp column_winner(_board, {_, _, color}, color, 4), do: color
  defp column_winner(board, {row, col, color} , color, count) do
    column_winner(board, Board.checker(board, {row-1, col}), color, count+1)
  end
  defp column_winner(_board, _checker, _color, _count), do: nil

  defp row_winner(_board, {_row, _col, :empty}), do: nil
  defp row_winner(board, {_row, _col, color} = checker) do
    row_winner(board, winner_start_checker(board, checker, 0), color, 1)
  end
  defp row_winner(_board, {_, _, color}, color, 4), do: color
  defp row_winner(board, {row, col, color}, color, count) do
    row_winner(board, Board.checker(board, {row, col+1}), color, count+1)
  end
  defp row_winner(_board, _checker, _color, _count), do: nil

  defp diagonal_winner(_board, {_row, _col, :empty}), do: nil
  defp diagonal_winner(board, {_row, _col, color} = checker) do
    diagonal_winner(board, winner_start_checker(board, checker, -1), +1, color, 1)
      || diagonal_winner(board, winner_start_checker(board, checker, +1), -1, color, 1)
  end
  defp diagonal_winner(_board, {_, _, color}, _row_diff, color, 4), do: color
  defp diagonal_winner(board, {row, col, color}, row_diff, color, count) do
    diagonal_winner(board, Board.checker(board, {row+row_diff, col+1}), row_diff, color, count+1)
  end
  defp diagonal_winner(_board, _checker, _diff, _color, _count), do: nil

  def winner_start_checker(board, {row, col, color}, row_diff) do
    row_left = row+row_diff
    col_left = col-1
    case Board.checker(board, {row_left, col_left}) do
      {row_left, col_left, color} ->
        winner_start_checker(board, {row_left, col_left, color}, row_diff)
      _ ->
        {row, col, color}
    end
  end
end

defimpl Poison.Encoder, for: ConnectFour.Games.Game do
  @moduledoc """
  Implements Poison.Encoder for Board
  """
  def encode(%ConnectFour.Games.Game{turns: turns} = game, _options)  do
    turns = for {col, color} <- turns, do: %{col: col, color: color}
    Poison.encode!(%{game | turns: turns} |> Map.from_struct)
  end

  def encode(game, _options) do
    raise Poison.EncodeError, value: game
  end
end
