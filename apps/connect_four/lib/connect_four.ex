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
  defdelegate start_game(game_id), to: ConnectFour.Client

  @doc """
  Join an existing existing game by game id, player id, and process id

  ## Examples

      iex> ConnectFour.start_game("game_2")
      iex> ConnectFour.join_game("game_2", "player", self())
      {:ok, %ConnectFour.Game{id: "game_2", red: "player"}}

  """
  defdelegate join_game(game_id, player_id, pid), to: ConnectFour.Client

  @doc """
  Fetch game state by game id.

  ## Examples

      iex> ConnectFour.start_game("game_3")
      iex> ConnectFour.fetch_game("game_3")
      %ConnectFour.Game{id: "game_3"}

  """
  defdelegate fetch_game(game_id), to: ConnectFour.Client

  @doc """
  Make game move by game id, player id, and column.

  ## Examples

      iex> ConnectFour.start_game("game_4")
      iex> ConnectFour.move("game_4", "player_1", 0)
      {:foul, "Game is not in play"}

  """
  defdelegate move(game_id, player_id, col), to: ConnectFour.Client

  @doc """
  Get next player whose turn it is.

  ## Examples

      iex> ConnectFour.start_game("game_5")
      iex> ConnectFour.join_game("game_5", "player_1", self())
      iex> ConnectFour.join_game("game_5", "player_2", self())
      iex> ConnectFour.next_player("game_5")
      {"player_1", :red}

  """
  defdelegate next_player(game_id), to: ConnectFour.Client
end
