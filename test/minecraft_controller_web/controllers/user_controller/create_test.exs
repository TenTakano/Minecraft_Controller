defmodule MinecraftControllerWeb.UserController.CreateTest do
  use MinecraftControllerWeb.ConnCase

  alias ExAws.Dynamo
  alias MinecraftController.Auth
  alias MinecraftController.Users.User

  @path "/api/users"

  describe "post/2" do
    setup %{conn: conn} do
      conn_with_header = put_req_header(conn, "content-type", "application/json")

      request = %{
        id: "someone",
        password: "password"
      }

      [conn: conn_with_header, request: request]
    end

    test "creates new user", %{conn: conn, request: request} do
      :meck.expect(ExCrypto, :generate_aes_key, fn _, _ -> {:ok, "somesalt"} end)
      post(conn, @path, request) |> assert_response(200, %{id: "someone"})

      expected_user = %User{
        id: "someone",
        salt: "somesalt",
        password_hash: Auth.hash_password("password", "somesalt")
      }

      assert Dynamo.get_item("Users", %{id: expected_user.id})
             |> ExAws.request!()
             |> Dynamo.decode_item(as: User) == expected_user
    end

    test "returns BadRequest for invalid request", %{conn: conn, request: request} do
      Enum.each(
        [
          %{},
          Map.delete(request, :id),
          Map.delete(request, :password)
        ],
        fn invalid_request ->
          post(conn, @path, invalid_request) |> assert_error(Error.BadRequest)
        end
      )
    end
  end
end
