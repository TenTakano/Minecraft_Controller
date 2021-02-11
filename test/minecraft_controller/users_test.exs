defmodule MinecraftController.Context.UsersTest do
  use MinecraftController.DataCase

  alias MinecraftController.Context.Users
  alias Users.User

  describe "get_user/1" do
    test "gets user" do
      user = %User{
        id: "someone",
        password_hash: "somehash",
        salt: "somesalt"
      }
      Dynamo.put_item("Users", user) |> ExAws.request!()

      assert Users.get_user(user.id) == {:ok, user}
    end
  end
end