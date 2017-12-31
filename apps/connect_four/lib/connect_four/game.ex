defmodule ConnectFour.Game do
  alias ConnectFour.{Game, Board, Winner}
  require Logger

  @type color :: :red | :black
  @type state :: :not_started | :in_play | :over

  defstruct [
    id: nil,
    red: nil,
    black: nil,
    next: nil,
    last: nil,
    turns: [],
    status: :not_started,
    winner: nil,
    board: Board.new
  ]

  def move(%Game{board: board, next: color} = game, player_id, {_col, color} = turn) do
    board
    |> Board.drop_checker(turn)
    |> complete_move(game, player_id, turn)
  end
  def move(%Game{status: status}, _player_id, _column) when status != :in_play, do: foul("Game is not in play")

  def move(%Game{next: _color_1}, _player_id, {_col, _color_2}), do: foul("Out of turn")
  def move(%Game{red: player_id} = game, player_id, column), do: move(game, player_id, {column, :red})
  def move(%Game{black: player_id} = game, player_id, column), do: move(game, player_id, {column, :black})
  def move(%Game{black: _black, red: _red}, _player_id, _column), do: foul("Player not playing")

  defp complete_move({:error, reason}, _game, _player_id, _turn), do: foul(reason)
  defp complete_move(%Board{} = board, %Game{} = game, player_id, turn) do
    game = %{game | board: board}
           |> switch_color
           |> add_turn(turn)
           |> add_winner

    {:ok, game}
  end
  defp foul(message), do: {:foul, message}

  def add_player(%Game{red: nil} = game, player_id), do: (%{game | red: player_id} |> start_game)
  def add_player(%Game{black: nil} = game, player_id), do: (%{game | black: player_id} |> start_game)
  def add_player(%Game{} = game, _player_id), do: game

  def start_game(%Game{red: nil} = game), do: game
  def start_game(%Game{black: nil} = game), do: game
  def start_game(%Game{status: :not_started} = game) do
    %{game | status: :in_play} |> start_game
  end
  def start_game(%Game{next: nil} = game) do
    %{game | next: :red}
  end
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
    %{game | status: :over}
  end
  defp end_game(game), do: game

  def winner(%Game{board: board}), do: Winner.winner(board)

  defp switch_color(%Game{next: color} = game) do
    next = case color do
      :red -> :black
      :black -> :red
      nil -> throw "Game not started"
      _ -> throw "Not a color: #{inspect color}"
    end
    %{game | next: next}
  end

  defp add_turn(%Game{turns: turns} = game, turn) do
    %{game | turns: [turn | turns]}
  end
end
