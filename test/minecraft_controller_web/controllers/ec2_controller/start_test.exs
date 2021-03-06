defmodule MinecraftControllerWeb.EC2Controller.StartTest do
  use MinecraftControllerWeb.ConnCase

  alias MinecraftController.EC2
  alias MinecraftController.Utils

  @path "/api/ec2/start"

  describe "get/2" do
    test "execute start script", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:ok, "started_instance_id"} end)
      :meck.expect(EC2, :start_instance, fn -> :ok end)

      :meck.expect(EC2, :get_instance, fn ->
        {:ok, %{status: "running", public_ip: "111.111.111.111"}}
      end)

      get(conn, @path) |> assert_response(200, %{ip: "111.111.111.111"})
    end

    test "returns 409 if wait sequence timeout", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:ok, "started_instance_id"} end)
      :meck.expect(EC2, :start_instance, fn -> :ok end)
      :meck.expect(EC2, :get_instance, fn -> {:ok, %{status: "pending", public_ip: nil}} end)
      :meck.expect(Utils, :wait_milliseconds, fn _ -> :ok end)
      get(conn, @path) |> assert_error(Error.AwsError)
    end
  end
end
