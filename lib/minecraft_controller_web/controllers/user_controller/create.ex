defmodule MinecraftControllerWeb.UserController.Create do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Users

  def post(conn, params) do
    with(
      {:ok, validated_params} <- validate_params(params),
      :ok <- Users.create_user(validated_params)
    ) do
      json(conn, Map.take(validated_params, [:id]))
    else
      :bad_request -> error_json(conn, Error.BadRequest)
      {:error, :already_taken} -> error_json(conn, Error.DuplicateId)
    end
  end

  defp validate_params(%{"id" => id, "password" => password}) do
    {:ok, %{id: id, password: password}}
  end

  defp validate_params(_), do: :bad_request
end
