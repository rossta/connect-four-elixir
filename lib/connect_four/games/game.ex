defmodule ConnectFour.Games.Game do
  @derive [Poison.Encoder]
  alias ConnectFour.Games.{Game, Board}
  require Logger

  @type state :: :not_started | :in_play | :finished

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
    winner = nil

    {:ok, %{game | winner: winner}}
  end

  def move(%{last: player_id}, player_id, _column), do: {:foul, "Not player's turn"}
  def move(%{red: player_id} = game, player_id, column), do: move(game, player_id, {column, :red})
  def move(%{black: player_id} = game, player_id, column), do: move(game, player_id, {column, :black})
  def move(%{black: black, red: red}, player_id, _column), do: {:foul, "Player not playing"}

  def add_player(%Game{red: nil} = game, player_id), do: %{game | red: player_id}
  def add_player(%Game{black: nil} = game, player_id), do: %{game | black: player_id}
  def add_player(%Game{} = game, _player_id), do: game

  def which_player(%Game{red: player_id}, player_id), do: :red
  def which_player(%Game{black: player_id}, player_id), do: :black
  def which_player(%Game{}, _player_id), do: nil

  def winner(%Game{board: board}), do: winner(board)
  def winner(%Board{last: nil}), do: nil
  def winner(%Board{cells: cells, last: last} = board) do
    column_winner(cells, last)
  end

  defp column_winner(_cells, {row, _col, _color}) when row + 1 < 4, do: nil
  defp column_winner(_cells, {_row, _col, :empty}), do: nil
  defp column_winner(cells, {row, col, color} = checker) do
    Logger.info "column_winner(cells, {#{row}, #{col}, #{color}})"
    column_winner(cells, checker, Board.checker(cells, {row-1, col}), 2)
  end
  defp column_winner(cells, {_, _, color}, {_, _, color}, 4), do: color
  defp column_winner(cells, {_, _, color} , {row, col, color} = checker, count) do
    Logger.info "column_winner(cells, {_, _, #{color}}, {#{row}, #{col}, #{color}}, #{count})"
    column_winner(cells, checker, Board.checker(cells, {row-1, col}), count+1)
  end
  defp column_winner(cells, {_, _, color1}, {_, _, color2}, count), do: nil
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
