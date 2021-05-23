defmodule MinecraftController.UsersTest do
  use MinecraftController.DataCase

  alias MinecraftController.Auth
  alias Users.User

  @table_name "Users"

  describe "create_user/1" do
    test "creates a new user" do
      expected = %User{id: "someone", salt: "somesalt", password_hash: "somehash"}
      :meck.expect(ExCrypto, :generate_aes_key, fn _, _ -> {:ok, expected.salt} end)
      :meck.expect(Auth, :hash_password, fn _, _ -> expected.password_hash end)

      assert Users.create_user(%{id: expected.id, password: "password"}) == :ok

      assert Dynamo.get_item(@table_name, %{id: expected.id})
             |> ExAws.request!()
             |> Dynamo.decode_item(as: User) == expected
    end

    test "returns error if given user id is already taken" do
      user_id = "someone"

      user = %User{
        id: user_id,
        password_hash: "somehash",
        salt: "somesalt"
      }

      Dynamo.put_item(@table_name, user) |> ExAws.request!()

      assert Users.create_user(%{id: user_id, password: "password"}) == {:error, :already_taken}
    end
  end

  describe "get_user/1" do
    test "gets user" do
      user = %User{
        id: "someone",
        password_hash: "somehash",
        salt: "somesalt"
      }

      Dynamo.put_item(@table_name, user) |> ExAws.request!()

      assert Users.get_user(user.id) == {:ok, user}
    end

    test "returns error for non-existence user id" do
      assert Users.get_user("non-existence") == {:error, :not_found}
    end
  end
end
