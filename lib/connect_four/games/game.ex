defmodule ConnectFour.Games.Game do
  alias ConnectFour.Games.Game

  defstruct [
    id: nil,
    red: nil,
    black: nil,
    turn: nil,
    turns: [],
    over: false,
    winner: nil,
  ]

  def add_player(%Game{red: nil} = game, player_id), do: %{game | red: player_id}
  def add_player(%Game{black: nil} = game, player_id), do: %{game | black: player_id}
end
