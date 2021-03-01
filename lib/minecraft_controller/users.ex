defmodule MinecraftController.Users do
  alias ExAws.Dynamo
  alias MinecraftController.Auth

  defmodule User do
    @derive [Dynamo.Encodable]
    defstruct [:id, :password_hash, :salt]
  end

  @table_name "Users"

  # TODO: need to check conflict
  @spec create_user(map) :: :ok
  def create_user(%{id: id, password: password}) do
    {:ok, salt} = ExCrypto.generate_aes_key(:aes_128, :base64)
    Dynamo.put_item(@table_name, %User{
      id: id,
      salt: salt,
      password_hash: Auth.hash_password(password, salt)
    })
    |> ExAws.request!()
    :ok
  end

  @spec get_user(String.t) :: {:ok, User.t} | {:error, :not_found}
  def get_user(user_id) do
    Dynamo.get_item(@table_name, %{id: user_id})
    |> ExAws.request!()
    |> Dynamo.decode_item(as: User)
    |> case do
      %{id: id} when is_nil(id) -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
end
