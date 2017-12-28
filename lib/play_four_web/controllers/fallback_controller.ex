defmodule PlayFourWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use PlayFourWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(PlayFourWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(PlayFourWeb.ErrorView, :"404")
  end

  # def call(conn, arg) do
  #   conn
  #   |> put_status(:unprocessable_entity)
  #   |> render(PlayFourWeb.ErrorView, inspect arg)
  # end
end
