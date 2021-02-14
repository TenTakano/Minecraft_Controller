defmodule MinecraftController.Users do
  alias ExAws.Dynamo

  defmodule User do
    @derive [Dynamo.Encodable]
    defstruct [:id, :password_hash, :salt]
  end

  @table_name "Users"

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
