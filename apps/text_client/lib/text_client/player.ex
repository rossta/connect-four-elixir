defmodule TextClient.Player do
  alias TextClient.{Prompter, State}
  require Logger

  def play(%State{} = state) do
    continue(state)
  end

  def continue(%State{game: game} = state) do
    state
    |> Prompter.summary()
    |> Prompter.accept_move(ConnectFour.next_player(game.id))
    |> play_move()
    |> play()
  end

  defp play_move(%State{attempt: {player_id, col}, game: game} = state) do
    {:ok, new_game} = ConnectFour.move(game.id, player_id, col)
    %{state | game: new_game}
  end
end
