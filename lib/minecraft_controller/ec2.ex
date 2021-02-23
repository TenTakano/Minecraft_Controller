defmodule MinecraftController.EC2 do
  alias ExAws.EC2

  @spec target_instance_id() :: String.t
  def target_instance_id() do
    Application.get_env(:minecraft_controller, __MODULE__)
    |> Keyword.fetch!(:target_instance_id)
  end

  @spec get_instance_status(String.t) :: map | nil
  def get_instance_status(instance_id) do
    EC2.describe_instances(filters: [{"instance-id", [instance_id]}])
    |> request!()
    |> case do
      nil -> nil
      instance ->
        %{
          status: get_in(instance, ["instanceState", "name"]),
          ip: get_in(instance, ["networkInterfaceSet", "item", "association", "publicIp"])
        }
    end
  end

  @spec start_instance(String.t) :: :ok
  def start_instance(instance_id) do
    %{status_code: 200} =
      instance_id
      |> List.wrap()
      |> EC2.start_instances()
      |> ExAws.request!()
    :ok
  end

  @spec stop_instance(String.t) :: :ok
  def stop_instance(instance_id) do
    %{status_code: 200} =
      instance_id
      |> List.wrap()
      |> EC2.stop_instances()
      |> ExAws.request!()
    :ok
  end

  @spec request!(map) :: map | nil
  defp request!(op) do
    %{status_code: 200, body: body} = ExAws.request!(op)
    XmlToMap.naive_map(body)
    |> get_in(["DescribeInstancesResponse", "reservationSet"])
    |> case do
      nil -> nil
      item -> get_in(item, ["item", "instancesSet", "item"])
    end
  end
end
