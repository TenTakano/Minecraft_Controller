defmodule MinecraftControllerWeb.EC2Controller.StartTest do
  use MinecraftControllerWeb.ConnCase

  alias MinecraftController.Context.EC2
  alias MinecraftController.Utils

  describe "get/2" do
    test "execute start script", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:ok, "started_instance_id"} end)
      :meck.expect(EC2, :start_instance, fn _ -> :ok end)
      :meck.expect(EC2, :get_instance_status, fn _ -> "running" end)
      expected = %{"instance_id" => "started_instance_id", "status" => "running"}

      assert %{status: 200, resp_body: body} = get(conn, "/api/ec2/start")
      assert Jason.decode!(body) == expected
    end

    test "returns 404 if target instance isn't setup", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:error, :not_found} end)
      expected = %{"message" => "Instance not found"}

      assert %{status: 404, resp_body: body} = get(conn, "/api/ec2/start")
      assert Jason.decode!(body) == expected
    end

    test "returns 409 if wait sequence timeout", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:ok, "started_instance_id"} end)
      :meck.expect(EC2, :start_instance, fn _ -> :ok end)
      :meck.expect(EC2, :get_instance_status, fn _ -> "pending" end)
      :meck.expect(Utils, :wait_milliseconds, fn _ -> :ok end)
      expected = %{"message" => "Something error occurs on AWS"}

      assert %{status: 409, resp_body: body} = get(conn, "/api/ec2/start")
      assert Jason.decode!(body) == expected
    end
  end
end
