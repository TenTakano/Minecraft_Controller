defmodule MinecraftController.Auth do
  alias ExCrypto.{Hash, Token}

  @stretch_number 3000
  @token_lifetime Application.get_env(:minecraft_controller, :auth) |> Keyword.get(:token_lifetime)

  @spec hash_password(String.t, String.t) :: String.t
  def hash_password(password, salt) do
    papper = get_secret_key()
    execute_hash(password <> salt <> papper, @stretch_number)
  end

  defp execute_hash(hash, 0), do: hash
  defp execute_hash(plain, count) do
    Hash.sha256!(plain)
    |> Base.encode16(case: :lower)
    |> execute_hash(count - 1)
  end

  @spec verify_password(String.t, String.t, String.t) :: boolean
  def verify_password(password, salt, expected_hash) do
    hash_password(password, salt) == expected_hash
  end

  @spec gen_access_token(map) :: String.t
  def gen_access_token(user) do
    user
    |> Map.fetch!(:id)
    |> Token.create!(get_secret_key())
  end

  @spec verify_access_token(String.t) :: {:ok, binary} | {:error, any}
  def verify_access_token(token) do
    Token.verify(token, get_secret_key(), @token_lifetime)
  end

  @spec get_secret_key() :: String.t
  def get_secret_key() do
    Application.get_env(:minecraft_controller, MinecraftControllerWeb.Endpoint)
    |> Keyword.fetch!(:secret_key_base)
  end
end
