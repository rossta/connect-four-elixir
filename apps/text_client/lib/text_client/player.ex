defmodule TextClient.Player do
  alias TextClient.{Prompter, State}
  require Logger

  def play(%State{game: %{ status: :over, winner: winner }}) do
    IO.puts "Game over! #{winner.color} wins."
    exit(:normal)
  end

  def play(%State{} = state) do
    continue(state)
  end

  def continue(%State{game: game} = state) do
    state
    |> Prompter.summary()
    |> accept_move(game)
    |> play_move()
    |> play()
  end

  defp accept_move(state, game) do
    state |> Prompter.accept_move(ConnectFour.next_player(game.id))
  end

  defp play_move(%State{attempt: {player_id, col}, game: game} = state) do
    {:ok, new_game} = ConnectFour.move(game.id, player_id, col)
    %{state | game: new_game}
  end
end
