defmodule MinecraftController.Context.EC2 do
  alias ExAws.EC2

  @tag_key "controller"
  @tag_value "minecraft_controller"

  @spec target_instance_id() :: String.t | nil
  def target_instance_id() do
    EC2.describe_instances(filters: [{"tag:#{@tag_key}", @tag_value}])
    |> request!()
    |> case do
      %{"item" => %{"instanceId" => instance_id}} -> instance_id
      nil -> nil
    end
  end

  @spec get_instance_status(String.t) :: String.t | nil
  def get_instance_status(instance_id) do
    EC2.describe_instances(filters: [{"insntance-id", instance_id}])
    |> request!()
    |> case do
      %{"item" => %{"instanceState" => %{"name" => status}}} -> status
      nil -> nil
    end
  end

  @spec start_instance(String.t) :: :ok
  def start_instance(instance_id) do
    EC2.start_instances([instance_id]) |> request!()
    :ok
  end

  @spec request!(map) :: map
  defp request!(op) do
    %{status_code: 200, body: body} = ExAws.request!(op)
    XmlToMap.naive_map(body) |> get_in(["DescribeInstancesResponse", "reservationSet"])
  end
end
