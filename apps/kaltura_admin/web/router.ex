defmodule KalturaAdmin.Router do
  use KalturaAdmin.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug KalturaAdmin.Authorization.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", KalturaAdmin do
    pipe_through [:browser, :auth]

    get "/", PageController, :index
    resources "/sessions", SessionController, only: [:new, :create]
    post "/logout", SessionController, :logout
  end

  scope "/", KalturaAdmin do
    pipe_through [:browser, :auth, :ensure_auth]

    resources "/channels", ChannelController
    resources "/users", UserController
  end
end
