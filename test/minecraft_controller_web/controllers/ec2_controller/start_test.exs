defmodule MinecraftControllerWeb.EC2Controller.StartTest do
  use MinecraftControllerWeb.ConnCase

  alias MinecraftController.Context.EC2

  describe "get/2" do
    test "execute start script", %{conn: conn} do
      :meck.expect(EC2, :target_instance_id, fn -> {:ok, "started_instance_id"} end)
      :meck.expect(EC2, :start_instance, fn _ -> :ok end)
      :meck.expect(EC2, :get_instance_status, fn _ -> "running" end)
      expected = %{"instance_id" => "started_instance_id", "status" => "running"}

      assert %{status: 200, resp_body: body} = get(conn, "/api/ec2/start")
      assert Jason.decode!(body) == expected
    end
  end
end
