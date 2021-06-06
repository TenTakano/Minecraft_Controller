defmodule MinecraftControllerWeb.UserController.UpdateTest do
  use MinecraftControllerWeb.ConnCase

  alias MinecraftController.{Auth, Users}
  alias Users.User
  alias MinecraftControllerWeb.Error

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

      path = @path_base <> "/" <> user.id

      [conn: conn_with_header, user: user, path: path]
    end

    test "updates user attribute", %{conn: conn, user: user_base, path: path} do
      :meck.expect(ExCrypto, :generate_aes_key, fn _, _ -> {:ok, user_base.salt} end)
      request = %{password: "another_pass"}
      put(conn, path, request) |> assert_response(200, %{id: user_base.id})

      expected_user = %User{
        id: user_base.id,
        salt: user_base.salt,
        password_hash: Auth.hash_password(request.password, user_base.salt)
      }

      assert {:ok, user} = Users.get_user(user_base.id)
      assert user == expected_user
    end

    test "returns 200 with do nothing for empty map", %{conn: conn, user: user_base, path: path} do
      {:ok, expected_user} = Users.get_user(user_base.id)
      put(conn, path, %{}) |> assert_response(200, %{id: user_base.id})

      assert {:ok, user} = Users.get_user(user_base.id)
      assert user == expected_user
    end

    test "returns 404 for non-existent user", %{conn: conn} do
      path = @path_base <> "/notfound"
      put(conn, path, %{password: "pass"}) |> assert_error(Error.ResourceNotFound)
    end
  end
end
