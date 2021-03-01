defmodule MinecraftControllerWeb.UserController.Create do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Users

  def post(conn, params) do
    json(conn, params)
  end
end
