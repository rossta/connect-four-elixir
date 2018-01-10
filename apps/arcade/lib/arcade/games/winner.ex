defimpl Poison.Encoder, for: ConnectFour.Winner do
  @moduledoc """
  Implements Poison.Encoder for Winner
  """
  def encode(%ConnectFour.Winner{color: color, moves: moves}, _options)  do
    moves = for {row, col} <- moves, do: %{row: row, col: col}

    Poison.encode!(%{color: color, moves: moves})
  end

  def encode(board, _options) do
    raise Poison.EncodeError, value: board
  end
end
