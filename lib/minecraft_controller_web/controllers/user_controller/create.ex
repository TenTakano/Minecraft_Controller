defmodule MinecraftControllerWeb.UserController.Create do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Users

  def post(conn, params) do
    case validate_params(params) do
      {:ok, _validated_params} ->
        json(conn, params)
      :bad_request ->
        error_json(conn, Error.BadRequest)
    end
  end

  defp validate_params(%{"id" => id, "password" => password}) do
    {:ok, %{id: id, password: password}}
  end
  defp validate_params(_), do: :bad_request
end
