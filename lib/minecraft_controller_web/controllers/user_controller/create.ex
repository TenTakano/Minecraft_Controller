defmodule MinecraftControllerWeb.UserController.Create do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Users

  def post(conn, params) do
    case validate_params(params) do
      {:ok, validated_params} ->
        case Users.create_user(validated_params) do
          :ok -> json(conn, Map.take(validated_params, [:id]))
          _ -> error_json(conn, Error.DuplicateId)
        end
      :bad_request ->
        error_json(conn, Error.BadRequest)
    end
  end

  defp validate_params(%{"id" => id, "password" => password}) do
    {:ok, %{id: id, password: password}}
  end
  defp validate_params(_), do: :bad_request
end
