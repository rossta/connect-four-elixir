defmodule ConnectFour.Games.Game do
  @derive [Poison.Encoder]
  alias ConnectFour.Games.{Game, Board}

  defstruct [
    id: nil,
    red: nil,
    black: nil,
    last: nil,
    turns: [],
    over: false,
    winner: nil,
    board: Board.new
  ]

  def move(%{board: board, turns: turns} = game, player_id, {_col, _color} = turn) do
    board = Board.drop_checker(board, turn)

    {:ok, %{game | board: board, last: player_id, turns: [turn | turns]}}
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
