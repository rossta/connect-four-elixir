defimpl Poison.Encoder, for: ConnectFour.Game do
  @moduledoc """
  Implements Poison.Encoder for Board
  """
  def encode(%ConnectFour.Game{turns: turns} = game, _options) do
    turns = for {col, color} <- turns, do: %{col: col, color: color}
    Poison.encode!(%{game | turns: turns} |> Map.from_struct())
  end

  def encode(game, _options) do
    raise Poison.EncodeError, value: game
  end
end
