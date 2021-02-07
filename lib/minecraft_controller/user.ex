defmodule MinecraftController.Context.User do
  alias MinecraftController.Auth

  # TODO: Need to be replaced with dynamoDB implementation
  def get_user(_user_id) do
    hash = Auth.hash_password("password", "somesolt")
    
    {:ok, %{id: "some_id", password_hash: hash, salt: "somesolt"}}
  end
end
