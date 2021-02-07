defmodule MinecraftController.Context.User do
  # TODO: Need to be replaced with dynamoDB implementation
  def get_user(_user_id) do
    secret = Application.get_env(:minecraft_controller, MinecraftControllerWeb.Endpoint) |> Keyword.fetch!(:secret_key_base)
    hash =
      "password" <> "somesolt" <> secret
      |> ExCrypto.Hash.sha256!()
      |> Base.encode16(case: :lower)
    
    {:ok, %{id: "some_id", password_hash: hash, solt: "somesolt"}}
  end
end
