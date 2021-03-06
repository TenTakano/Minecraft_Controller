defmodule MinecraftControllerWeb.UserController.Login do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Auth
  alias MinecraftController.Users

  def post(conn, params) do
    with(
      {:ok, %{id: user_id, password: password}} <- validate_params(params),
      {:ok, user} <- Users.get_user(user_id),
      true <- Auth.verify_password(password, user.salt, user.password_hash)
    ) do
      res_body = %{token: Auth.gen_access_token(user)}
      json(conn, res_body)
    else
      :bad_request -> error_json(conn, Error.BadRequest)
      _ -> error_json(conn, Error.ResourceNotFound)
    end
  end

  @spec validate_params(map) :: {:ok, map} | :bad_request
  defp validate_params(%{"id" => id, "password" => password}) do
    {:ok, %{id: id, password: password}}
  end

  defp validate_params(_), do: :bad_request
end
