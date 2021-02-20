defmodule MinecraftControllerWeb.Version do
  use MinecraftControllerWeb, :controller

  def get(conn, _) do
    json(conn, %{version: "0.1.0"})
  end
end
