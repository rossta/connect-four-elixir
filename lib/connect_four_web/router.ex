defmodule ConnectFourWeb.Router do
  use ConnectFourWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ConnectFourWeb do
    pipe_through :api

    resources "/players", PlayerController
    resources "/games", GameController
  end
end
