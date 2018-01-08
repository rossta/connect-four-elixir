defmodule TextClient.Prompter do
  alias TextClient.State
  require Logger

  def summary(%State{game: game} = state) do
    IO.puts [
      "\n",
      "#{inspect game.board}\n",
      "\n"
    ]
    state
  end

  def accept_move(%State{player_id: player_id} = state, {player_id, color} = turn) do
    IO.gets("Your move [#{color}]: ")
    |> check_input(turn, state)
    |> add_move(player_id, state)
  end

  def accept_move(%State{client_id: client_id, game: game} = state, {client_id, color}) do
    IO.puts("Computer's move [#{color}]...")
    Logger.debug "accept_move: #{inspect game}"
    Joshua.pick_move(game, color)
    |> add_move(client_id, state)
  end

  def add_move({col, _color}, player_id, state) do
    %{state | attempt: {player_id, col}}
  end

  defp check_input({:error, reason}, _, _) do
    IO.puts("Game ended: #{reason}")
    exit(:normal)
  end

  defp check_input(:eof, _, _) do
    IO.puts("Looks like you gave up...}")
    exit(:normal)
  end

  defp check_input(input, {_player_id, color} = turn, %State{} = state) do
    input = String.trim(input)
    cond do
      input =~ ~r/\A[0-6]\z/ ->
        {input |> String.to_integer, color}
      true ->
        IO.puts "Please enter a valid column number"
        accept_move(state, turn)
    end
  end
end
