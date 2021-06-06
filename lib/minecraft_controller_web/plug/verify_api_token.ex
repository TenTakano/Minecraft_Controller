defmodule MinecraftControllerWeb.Plug.VerifyApiToken do
  use MinecraftControllerWeb, :controller

  alias Plug.Conn
  alias MinecraftController.Auth
  alias MinecraftControllerWeb.Error.BadRequest

  def call(conn, _) do
    if Mix.env() in [:dev, :prod] do
      validate_token(conn)
    else
      mock_token_validation(conn)
    end
  end

  def validate_token(conn) do
    with(
      [token] <- Conn.get_req_header(conn, "authorization"),
      {:ok, user_id} <- Auth.verify_access_token(token)
    ) do
      Conn.assign(conn, :user_id, user_id)
    else
      _ -> error_json(conn, BadRequest) |> halt()
    end
  end

  defp mock_token_validation(conn) do
    case Conn.get_req_header(conn, "mocked_user_id") do
      [] -> conn
      [user_id] -> Conn.assign(conn, :user_id, user_id)
    end
  end
end
