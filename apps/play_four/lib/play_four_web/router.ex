defmodule PlayFourWeb.Router do
  use PlayFourWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PlayFourWeb do
    pipe_through :api

    get "/", GameController, :index

    resources "/players", PlayerController
    resources "/games", GameController
  end
end
