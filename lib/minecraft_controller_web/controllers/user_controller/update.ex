defmodule MinecraftControllerWeb.UserController.Update do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Users

  def put(%{path_params: %{"user_id" => user_id}} = conn, params) do
    with(
      _validated_params <- validate_params(params),
      {:ok, _user} <- Users.get_user(user_id)
    ) do
      json(conn, %{id: user_id})
    else
      {:error, :not_found} -> error_json(conn, Error.ResourceNotFound)
    end
  end

  defp validate_params(params) do
    params
    |> Enum.filter(fn {key, _} -> key in ["password"] end)
    |> Enum.into(%{}, fn {key, value} -> {String.to_existing_atom(key), value} end)
  end
end
