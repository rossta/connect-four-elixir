defmodule ConnectFourWeb.Router do
  use ConnectFourWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", ConnectFourWeb do
    pipe_through :api
  end
end
