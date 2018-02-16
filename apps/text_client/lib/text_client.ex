defmodule TextClient do
  @moduledoc """
  Documentation for TextClient.
  """

  alias TextClient.{State, Player}

  @id_length 8

  def start() do
    new_game()
    |> setup_state()
    |> Player.play()
  end

  def new_game() do
    ConnectFour.start_game(new_id())
  end

  def new_id do
    @id_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, @id_length)
  end

  def setup_state({:ok, game}) do
    player_id = new_id()
    client_id = new_id()
    ConnectFour.join_game(game.id, player_id, self())
    {:ok, game} = ConnectFour.join_game(game.id, client_id, self())

    %State{
      game: game,
      player_id: player_id,
      client_id: client_id
    }
  end
end
