defmodule MinecraftController.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # MinecraftController.Repo,
      # Start the Telemetry supervisor
      MinecraftControllerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MinecraftController.PubSub},
      # Start the Endpoint (http/https)
      MinecraftControllerWeb.Endpoint,
      # Start a worker by calling: MinecraftController.Worker.start_link(arg)
      # {MinecraftController.Worker, arg}
      MinecraftController.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MinecraftController.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MinecraftControllerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
