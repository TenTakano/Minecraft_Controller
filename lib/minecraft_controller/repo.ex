defmodule MinecraftController.Repo do
  use Ecto.Repo,
    otp_app: :minecraft_controller,
    adapter: Ecto.Adapters.Postgres
end
