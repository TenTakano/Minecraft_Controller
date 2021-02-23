defmodule MinecraftController.EC2Test do
  use MinecraftController.DataCase

  setup do
    instance_id = "some_instance_id"
    xml = """
      <DescribeInstancesResponse>
        <reservationSet>
          <item>
            <instancesSet>
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
                <instanceState>
                  <code>80</code>
                  <name>stopped</name>
                </instanceState>
              </item>
            </instancesSet>
          </item>
        </reservationSet>
      </DescribeInstancesResponse>
      """
    xml_without_instance = """
      <DescribeInstancesResponse>
        <reservationSet>
        </reservationSet>
      </DescribeInstancesResponse>
      """

    [instance_id: instance_id, xml: xml, xml_without_instance: xml_without_instance]
  end

  describe "get_instance_status/1" do
    test "returns instance status", %{instance_id: instance_id, xml: xml} do
      :meck.expect(ExAws, :request!, fn %{params: %{"Filter.1.Name" => filter_name, "Filter.1.Value.1" => filter_value}} ->
        send(self(), {filter_name, filter_value})
        %{status_code: 200, body: xml}
      end)
      assert EC2.get_instance_status(instance_id) == %{status: "stopped", ip: nil}
      assert_received {"instance-id", instance_id}
    end

    test "returns nil if target instance doesn't exist", ctx do
      %{instance_id: instance_id, xml_without_instance: xml_without_instance} = ctx
      :meck.expect(ExAws, :request!, fn _ -> %{status_code: 200, body: xml_without_instance} end)
      assert EC2.get_instance_status(instance_id) |> is_nil()
    end
  end

  describe "start_instance/1" do
    test "starts instance" do
      xml =
        """
          <StartInstancesResponse>
            <instancesSet>
              <item>
                <currentState>
                  <code>16</code>
                  <name>running</code>
                </currentState>
                <instanceId>instance_id</instanceId>
                <previousState>
                  <code>16</code>
                  <name>running</name>
                </previousState>
              </item>
            </instancesSet>
          </StartInstancesResponse>
        """
      :meck.expect(ExAws, :request!, fn _ -> %{status_code: 200, body: xml} end)
      assert :ok = EC2.start_instance("instance_id")
    end
  end
end
