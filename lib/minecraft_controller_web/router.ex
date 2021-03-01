defmodule MinecraftControllerWeb.Router do
  use MinecraftControllerWeb, :router

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

  if Mix.env() in [:dev, :prod] do
    pipeline :api_with_auth do
      plug :accepts, ["json"]
      plug MinecraftControllerWeb.Plug.VerifyApiToken
    end
  else
    pipeline :api_with_auth do
      plug :accepts, ["json"]
    end
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MinecraftControllerWeb.Telemetry
    end
  end

  scope "/api", MinecraftControllerWeb do
    pipe_through :api

    post "/users/login", UserController.Login, :post

    get "/version", Version, :get
  end

  scope "/api", MinecraftControllerWeb do
    pipe_through :api_with_auth

    get "/ec2/start", EC2Controller.Start, :get

    post "/users", UserController.Create, :post
  end

  scope "/", MinecraftControllerWeb do
    pipe_through :browser

    get "/*path", PageController, :index
  end
end
