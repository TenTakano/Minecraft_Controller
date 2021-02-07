defmodule MinecraftController.Auth do
  @spec hash_password(String.t, String.t) :: String.t
  def hash_password(password, salt) do
    papper = get_secret_key()
    ExCrypto.Hash.sha256!(password <> salt <> papper) |> Base.encode16(case: :lower)
  end

  @spec verify_password(String.t, String.t, String.t) :: boolean
  def verify_password(password, salt, expected_hash) do
    hash_password(password, salt) == expected_hash
  end

  @spec gen_access_token(map) :: String.t
  def gen_access_token(user) do
    user
    |> Map.fetch!(:id)
    |> ExCrypto.Token.create!(get_secret_key())
  end

  @spec get_secret_key() :: String.t
  def get_secret_key() do
    Application.get_env(:minecraft_controller, MinecraftControllerWeb.Endpoint)
    |> Keyword.fetch!(:secret_key_base)
  end
end
