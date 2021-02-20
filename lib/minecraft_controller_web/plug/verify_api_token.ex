defmodule MinecraftControllerWeb.Plug.VerifyApiToken do
  use MinecraftControllerWeb, :controller

  alias Plug.Conn
  alias MinecraftController.Auth
  alias MinecraftControllerWeb.Error.BadRequest

  def call(conn, _) do
    with(
      [token] <- Conn.get_req_header(conn, "authorization"),
      {:ok, user_id} <- Auth.verify_access_token(token)
    ) do
      Conn.assign(conn, :user_id, user_id)
    else
      _ -> error_json(conn, BadRequest) |> halt()
    end
  end
end
