defmodule RumblWeb.Router do
  use RumblWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(RumblWeb.Auth, repo: Rumbl.Repo)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/accounts", RumblWeb.Accounts, as: :accounts do
    pipe_through(:browser)
    resources("/users", UserController)
    resources("/sessions", SessionController, only: [:new, :create, :delete])
  end

  scope "/", RumblWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RumblWeb do
  #   pipe_through :api
  # end
end
