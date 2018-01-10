defmodule ArcadeWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ArcadeWeb, :controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(ArcadeWeb.ErrorView, :"404")
  end

  def call(conn, arg) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(ArcadeWeb.ErrorView, inspect arg)
  end
end
