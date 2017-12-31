defmodule ConnectFour do
  @moduledoc """
  Documentation for ConnectFour.
  """

  @doc """
  Start a new game by game id.

  ## Examples

      iex> ConnectFour.start_game("game_1")
      {:ok, %ConnectFour.Game{id: "game_1"}}

  """
  defdelegate start_game(game_id), to: ConnectFour.Cache

  @doc """
  Join an existing existing game by game id, player id, and process id

  ## Examples

      iex> ConnectFour.start_game("game_2")
      iex> ConnectFour.join_game("game_2", "player", self())
      {:ok, %ConnectFour.Game{id: "game_2", red: "player"}}

  """
  defdelegate join_game(game_id, player_id, pid), to: ConnectFour.Cache

  @doc """
  Fetch game state by game id.

  ## Examples

      iex> ConnectFour.start_game("game_3")
      iex> ConnectFour.fetch_game("game_3")
      %ConnectFour.Game{id: "game_3"}

  """
  defdelegate fetch_game(game_id), to: ConnectFour.Cache

  @doc """
  Make game move by game id, player id, and column.

  ## Examples

      iex> ConnectFour.start_game("game_4")
      iex> ConnectFour.move("game_4", "player_1", 0)
      {:foul, "Game is not in play"}

  """
  defdelegate move(game_id, player_id, col), to: ConnectFour.Cache
end
