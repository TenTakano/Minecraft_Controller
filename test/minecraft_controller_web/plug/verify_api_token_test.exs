defmodule MinecraftControllerWeb.Plug.VerifyApiTokenTest do
  use MinecraftController.CommonCase

  alias Plug.Conn
  alias MinecraftController.Auth

  describe "call/2" do
    setup do
      conn = Phoenix.ConnTest.build_conn()
      token = Auth.gen_access_token(%{id: "someone"})
      [conn: conn, token: token]
    end

    test "assigns valid api token", %{conn: conn_base, token: token} do
      conn = Conn.put_req_header(conn_base, "authorization", token)
      assert %{assigns: %{user_id: "someone"}} = VerifyApiToken.validate_token(conn)
    end

    test "returns BadRequest if header doesn't have authorization header", %{conn: conn} do
      assert %{status: 400} = VerifyApiToken.validate_token(conn)
    end

    test "returns BadRequest for invalid api token", %{conn: conn_base} do
      conn = Conn.put_req_header(conn_base, "authorization", "invalidtoken")
      assert %{status: 400} = VerifyApiToken.validate_token(conn)
    end
  end
end
