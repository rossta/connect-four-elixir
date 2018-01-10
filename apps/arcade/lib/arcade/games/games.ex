defmodule Arcade.Games do
  @moduledoc """
  The Games context.
  """

  @id_length 16

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

  """
  def create_player(_attrs \\ %{}) do
    id = @id_length
         |> :crypto.strong_rand_bytes
         |> Base.url_encode64()
         |> binary_part(0, @id_length)

    {:ok, %ConnectFour.Player{id: id}}
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

  """
  def create_game(_attrs \\ %{}) do
    id = @id_length
         |> :crypto.strong_rand_bytes
         |> Base.url_encode64()
         |> binary_part(0, @id_length)

    ConnectFour.start_game(id)
  end
end
