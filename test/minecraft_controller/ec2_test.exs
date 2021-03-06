defmodule MinecraftController.EC2Test do
  use MinecraftController.DataCase

  describe "get_instance/0" do
    setup do
      xml = """
      <DescribeInstancesResponse>
        <reservationSet>
          <item>
            <instancesSet>
              <item>
                <instanceId>some_instance_id</instanceId>
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
                <privateIpAddress>111.111.111.111</privateIpAddress>
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

      [xml: xml, xml_without_instance: xml_without_instance]
    end

    test "returns instance status", %{xml: xml} do
      :meck.expect(ExAws, :request!, fn %{
                                          params: %{
                                            "Filter.1.Name" => filter_name,
                                            "Filter.1.Value.1" => filter_value
                                          }
                                        } ->
        send(self(), {filter_name, filter_value})
        %{status_code: 200, body: xml}
      end)

      assert EC2.get_instance() ==
               {:ok, %{status: "stopped", public_ip: nil, private_ip: "111.111.111.111"}}

      assert_received {"instance-id", instance_id}
    end

    test "returns nil if target instance doesn't exist", ctx do
      %{xml_without_instance: xml_without_instance} = ctx
      :meck.expect(ExAws, :request!, fn _ -> %{status_code: 200, body: xml_without_instance} end)
      assert EC2.get_instance() == {:error, :instance_not_found}
    end
  end

  describe "start_instance/1" do
    test "starts instance" do
      xml = """
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
      assert :ok = EC2.start_instance()
    end
  end
end
