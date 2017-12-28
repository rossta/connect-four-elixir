defmodule PlayFour.Games do
  @moduledoc """
  The Games context.
  """

  # import Ecto.Query, warn: false
  # alias PlayFour.Repo

  alias PlayFour.{Games}
  alias PlayFour.Games.{Player, Game}

  @id_length 16

  # @doc """
  # Returns the list of players.
  #
  # ## Examples
  #
  #     iex> list_players()
  #     [%Player{}, ...]
  #
  # """
  # def list_players do
  #   Repo.all(Player)
  # end
  #
  # @doc """
  # Gets a single player.
  #
  # Raises `Ecto.NoResultsError` if the Player does not exist.
  #
  # ## Examples
  #
  #     iex> get_player!(123)
  #     %Player{}
  #
  #     iex> get_player!(456)
  #     ** (Ecto.NoResultsError)
  #
  # """
  # def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(_attrs \\ %{}) do
    id = @id_length
         |> :crypto.strong_rand_bytes
         |> Base.url_encode64()
         |> binary_part(0, @id_length)

    {:ok, %Player{id: id}}
  end

  # @doc """
  # Updates a player.
  #
  # ## Examples
  #
  #     iex> update_player(player, %{field: new_value})
  #     {:ok, %Player{}}
  #
  #     iex> update_player(player, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def update_player(%Player{} = player, attrs) do
  #   player
  #   |> Player.changeset(attrs)
  #   |> Repo.update()
  # end
  #
  # @doc """
  # Deletes a Player.
  #
  # ## Examples
  #
  #     iex> delete_player(player)
  #     {:ok, %Player{}}
  #
  #     iex> delete_player(player)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_player(%Player{} = player) do
  #   Repo.delete(player)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking player changes.
  #
  # ## Examples
  #
  #     iex> change_player(player)
  #     %Ecto.Changeset{source: %Player{}}
  #
  # """
  # def change_player(%Player{} = player) do
  #   Player.changeset(player, %{})
  # end

  # @doc """
  # Returns the list of games.
  #
  # ## Examples
  #
  #     iex> list_games()
  #     [%Game{}, ...]
  #
  # """
  # def list_games do
  #   Repo.all(Game)
  # end
  #
  # @doc """
  # Gets a single game.
  #
  # Raises `Ecto.NoResultsError` if the Game does not exist.
  #
  # ## Examples
  #
  #     iex> get_game!(123)
  #     %Game{}
  #
  #     iex> get_game!(456)
  #     ** (Ecto.NoResultsError)
  #
  # """
  # def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(_attrs \\ %{}) do
    id = @id_length
         |> :crypto.strong_rand_bytes
         |> Base.url_encode64()
         |> binary_part(0, @id_length)

    case Games.Cache.start_server(id) do
      {:ok, _pid} ->
        {:ok, %Game{id: id}}
      err ->
        err
    end
  end

  # @doc """
  # Updates a game.
  #
  # ## Examples
  #
  #     iex> update_game(game, %{field: new_value})
  #     {:ok, %Game{}}
  #
  #     iex> update_game(game, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def update_game(%Game{} = game, attrs) do
  #   game
  #   |> Game.changeset(attrs)
  #   |> Repo.update()
  # end
  #
  # @doc """
  # Deletes a Game.
  #
  # ## Examples
  #
  #     iex> delete_game(game)
  #     {:ok, %Game{}}
  #
  #     iex> delete_game(game)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_game(%Game{} = game) do
  #   Repo.delete(game)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking game changes.
  #
  # ## Examples
  #
  #     iex> change_game(game)
  #     %Ecto.Changeset{source: %Game{}}
  #
  # """
  # def change_game(%Game{} = game) do
  #   Game.changeset(game, %{})
  # end
end