defmodule ArcadeWeb.Router do
  use ArcadeWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ArcadeWeb do
    pipe_through(:api)

    get("/", GameController, :index)

    resources("/players", PlayerController)
    resources("/games", GameController)
  end
end
