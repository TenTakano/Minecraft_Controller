defmodule MinecraftControllerWeb.UserController.UpdateTest do
  use MinecraftControllerWeb.ConnCase

  @path_base "/api/users"

  describe "update/2" do
    test "updates user", %{conn: conn} do
      put(conn, @path_base <> "/someone", %{}) |> assert_response(200, %{})
    end
  end
end
