defmodule ConnectFour.Games.Game do
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

  def move(%{board: board, turns: turns} = game, player_id, {_color, _column} = checker) do
    board = Board.drop_checker(board, checker)

    {:ok, %{game | board: board, last: player_id, turns: [checker | turns]}}
  end

  def move(%{last: player_id}, player_id, _column), do: {:foul, "Not player's turn"}
  def move(%{red: player_id} = game, player_id, column), do: move(game, player_id, {:red, column})
  def move(%{black: player_id} = game, player_id, column), do: move(game, player_id, {:black, column})
  def move(%{black: black, red: red}, player_id, _column), do: {:foul, "Player not playing"}

  def add_player(%Game{red: nil} = game, player_id), do: %{game | red: player_id}
  def add_player(%Game{black: nil} = game, player_id), do: %{game | black: player_id}
  def add_player(%Game{} = game, _player_id), do: game

  def which_player(%Game{red: player_id}, player_id), do: :red
  def which_player(%Game{black: player_id}, player_id), do: :black
  def which_player(%Game{}, _player_id), do: nil
end
