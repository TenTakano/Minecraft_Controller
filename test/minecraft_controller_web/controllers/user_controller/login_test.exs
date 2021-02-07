defmodule MinevraftControllerWeb.UserController.LoginTest do
  use MinecraftControllerWeb.ConnCase

  describe "post/2" do
    setup %{conn: conn} do
      [conn: put_req_header(conn, "content-type", "application/json")]
    end

    test "generates access token from user attributes and returns it", %{conn: conn} do
      req_body = %{id: "some_id", password: "password"}

      assert %{status: 200, resp_body: body} = post(conn, "/api/users/login", req_body)
      assert %{"token" => _} = Jason.decode!(body)
    end
  end
end
