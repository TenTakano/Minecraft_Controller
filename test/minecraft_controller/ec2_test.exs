defmodule MinecraftController.Context.EC2Test do
  use MinecraftController.DataCase

  alias MinecraftController.Context.EC2

  describe "target_instance_id/0" do
    test "returns instance_id" do
      instance_id = "some_instance_id"
      :meck.expect(ExAws, :request!, fn _ ->
        body =
          """
          <DescribeInstancesResponse>
            <reservationSet>
              <item>
                <instanceId>main_instance_id</instanceId>
                <tagSet>
                  <item>
                    <key>Name</key>
                    <value>Main</value>
                  </item>
                </tagSet>
              </item>
              <item>
                <instanceId>#{instance_id}</instanceId>
                <tagSet>
                  <item>
                    <key>Name</key>
                    <value>Minecraft</value>
                  </item>
                  <item>
                    <key>controller</key>
                    <value>minecraft-controller</value>
                  </item>
                </tagSet>
              </item>
            </reservationSet>
          </DescribeInstancesResponse>
          """
        %{status_code: 200, body: body}
      end)

      assert EC2.target_instance_id() == instance_id
    end

    test "returns nil if target instance doesn't exist" do
      :meck.expect(ExAws, :request!, fn _ ->
        body =
          """
          <DescribeInstancesResponse>
            <reservationSet>
              <item>
                <instanceId>main_instance_id</instanceId>
                <tagSet>
                  <item>
                    <key>Name</key>
                    <value>Main</value>
                  </item>
                </tagSet>
              </item>
            </reservationSet>
          </DescribeInstancesResponse>
          """
        %{status_code: 200, body: body}
      end)

      assert EC2.target_instance_id() |> is_nil()
    end
  end
end
