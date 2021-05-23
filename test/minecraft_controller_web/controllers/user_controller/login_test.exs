defmodule MinecraftControllerWeb.UserController.LoginTest do
  use MinecraftControllerWeb.ConnCase

  alias ExCrypto.Token
  alias MinecraftController.Users

  @path "/api/users/login"

  describe "post/2" do
    setup %{conn: conn} do
      login_info = %{id: "someone", password: "somenicepassword"}
      Users.create_user(login_info)
      [conn: put_req_header(conn, "content-type", "application/json"), login_info: login_info]
    end

    test "generates access token from user attributes and returns it", %{conn: conn, login_info: login_info} do
      expected_token = "sometoken"
      :meck.expect(Token, :create!, fn _, _ -> expected_token end)
      post(conn, @path, login_info) |> assert_response(200, %{token: expected_token})
    end

    test "returns ResourceNotFound when login info doesn't match with any users", %{conn: conn, login_info: login_info} do
      Enum.each([
        Map.put(login_info, :id, "another"),
        Map.put(login_info, :password, "invalid")
      ], fn invalid_login_info ->
        post(conn, @path, invalid_login_info) |> assert_error(Error.ResourceNotFound)
      end)
    end
  end
end
