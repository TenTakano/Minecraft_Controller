defmodule MinecraftController.Users do
  alias ExAws.Dynamo
  alias MinecraftController.Auth

  defmodule User do
    @derive [Dynamo.Encodable]
    defstruct [:id, :password_hash, :salt]
  end

  @table_name "Users"

  @spec create_user(map) :: :ok | {:error, :already_taken}
  def create_user(%{id: id, password: password}) do
    case get_user(id) do
      {:error, :not_found} ->
        {:ok, salt} = ExCrypto.generate_aes_key(:aes_128, :base64)

        Dynamo.put_item(@table_name, %User{
          id: id,
          salt: salt,
          password_hash: Auth.hash_password(password, salt)
        })
        |> ExAws.request!()

        :ok

      _ ->
        {:error, :already_taken}
    end
  end

  @spec get_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(user_id) do
    Dynamo.get_item(@table_name, %{id: user_id})
    |> ExAws.request!()
    |> Dynamo.decode_item(as: User)
    |> case do
      %{id: id} when is_nil(id) -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  # need to refactoring
  @spec update_user(String.t(), map) :: :ok | {:error, :already_taken}
  def update_user(user_id, %{password: password}) do
    {:ok, salt} = ExCrypto.generate_aes_key(:aes_128, :base64)

    Dynamo.put_item(@table_name, %User{
      id: user_id,
      salt: salt,
      password_hash: Auth.hash_password(password, salt)
    })
    |> ExAws.request!()

    :ok
  end
end
