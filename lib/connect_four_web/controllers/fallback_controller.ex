defmodule ConnectFourWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ConnectFourWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ConnectFourWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ConnectFourWeb.ErrorView, :"404")
  end

  # def call(conn, arg) do
  #   conn
  #   |> put_status(:unprocessable_entity)
  #   |> render(ConnectFourWeb.ErrorView, inspect arg)
  # end
end
