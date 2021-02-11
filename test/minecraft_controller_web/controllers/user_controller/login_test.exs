defmodule MinecraftControllerWeb.UserController.LoginTest do
  use MinecraftControllerWeb.ConnCase

  alias ExCrypto.Token
  alias MinecraftController.Auth
  alias MinecraftController.Context.Users
  alias Users.User

  describe "post/2" do
    setup %{conn: conn} do
      [conn: put_req_header(conn, "content-type", "application/json")]
    end

    test "generates access token from user attributes and returns it", %{conn: conn} do
      user = %User{
        id: "someone",
        salt: "somesalt",
        password_hash: Auth.hash_password("password", "somesalt")
      }
      :meck.expect(Users, :get_user, fn _ -> {:ok, user} end)
      :meck.expect(Token, :create!, fn (_, _) -> "sometoken" end)
      expected = %{"token" => "sometoken"}

      req_body = %{id: "some_id", password: "password"}
      assert %{status: 200, resp_body: body} = post(conn, "/api/users/login", req_body)
      assert Jason.decode!(body) == expected
    end
  end
end
