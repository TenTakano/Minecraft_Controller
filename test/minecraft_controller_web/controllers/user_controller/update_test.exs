defmodule MinecraftControllerWeb.UserController.UpdateTest do
  use MinecraftControllerWeb.ConnCase

  alias ExAws.Dynamo
  alias MinecraftController.{Auth, Users}
  alias Users.User

  @path_base "/api/users"

  describe "update/2" do
    setup %{conn: conn} do
      conn_with_header = put_req_header(conn, "content-type", "application/json")

      user = %{
        id: "someone",
        salt: "somasalt",
        password: "password"
      }

      Users.create_user(user)

      [conn: conn_with_header, user: user]
    end

    test "updates user attribute", %{conn: conn, user: user_base} do
      :meck.expect(ExCrypto, :generate_aes_key, fn _, _ -> {:ok, user_base.salt} end)
      request = %{password: "another_pass"}
      path = @path_base <> "/" <> user_base.id
      put(conn, path, request) |> assert_response(200, %{id: "someone"})

      expected_user = %User{
        id: user_base.id,
        salt: user_base.salt,
        password_hash: Auth.hash_password(request.password, user_base.salt)
      }

      assert Dynamo.get_item("Users", %{id: user_base.id})
             |> ExAws.request!()
             |> Dynamo.decode_item(as: User) == expected_user
    end
  end
end
