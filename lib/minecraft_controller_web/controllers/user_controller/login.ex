defmodule MinecraftControllerWeb.UserController.Login do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Context.User

  def post(conn, params) do
    with(
      {:ok, %{id: user_id, password: password}} <- validate_params(params),
      {:ok, user} <- User.get_user(user_id),
      true <- validate_password(password, user)
    )
    do
      json(conn, %{"token" => gen_access_token(user)})
    else
      :bad_request -> conn |> put_status(400) |> json(%{message: "Given parameters were invalid."})
      false -> conn |> put_status(401) |> json(%{message: "Failed to log in."})
    end
  end

  @spec validate_params(map) :: {:ok, map} | :bad_request
  defp validate_params(%{"id" => id, "password" => password}) do
      {:ok, %{id: id, password: password}}
  end
  defp validate_params(_), do: :bad_request

  @spec validate_password(String.t, map) :: boolean
  defp validate_password(password, %{password_hash: expected_hash, solt: solt}) do
    papper = Application.get_env(:minecraft_controller, MinecraftControllerWeb.Endpoint) |> Keyword.fetch!(:secret_key_base)
    hash = ExCrypto.Hash.sha256!(password <> solt <> papper) |> Base.encode16(case: :lower)
    hash == expected_hash
  end

  @spec gen_access_token(map) :: String.t
  defp gen_access_token(user) do
    plain_text = Jason.encode!(%{user_id: user.id})
    secret = Application.get_env(:minecraft_controller, MinecraftControllerWeb.Endpoint) |> Keyword.fetch!(:secret_key_base)
    ExCrypto.Token.create!(plain_text, secret)
  end
end
