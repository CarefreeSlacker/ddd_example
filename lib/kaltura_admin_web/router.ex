defmodule CtiKalturaWeb.Router do
  use CtiKalturaWeb, :router

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

  pipeline :auth do
    plug(CtiKaltura.Authorization.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  scope "/", CtiKaltura do
    pipe_through([:browser, :auth])

    get("/", PageController, :index)
    resources("/sessions", SessionController, only: [:new, :create])
    post("/logout", SessionController, :logout)
  end

  scope "/", CtiKaltura do
    pipe_through([:browser, :auth, :ensure_auth])

    resources("/users", UserController)
    resources("/servers", ServerController)
    resources("/server_groups", ServerGroupController)
    resources("/regions", RegionController)
    resources("/subnets", SubnetController)
    resources("/linear_channels", LinearChannelController)
    resources("/tv_streams", TvStreamController)
    resources("/programs", ProgramController)
    resources("/program_records", ProgramRecordController)
  end
end
