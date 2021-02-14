defmodule MinecraftController.Context.EC2 do
  alias ExAws.EC2

  @tag_key "controller"
  @tag_value "minecraft_controller"

  @spec target_instance_id() :: {:ok, String.t} | {:error, :not_found}
  def target_instance_id() do
    EC2.describe_instances(filters: [{"tag:#{@tag_key}", @tag_value}])
    |> request!()
    |> case do
      %{"instanceId" => instance_id} -> {:ok, instance_id}
      nil -> {:error, :not_found}
    end
  end

  @spec get_instance_status(String.t) :: String.t | nil
  def get_instance_status(instance_id) do
    EC2.describe_instances(filters: [{"instance-id", [instance_id]}])
    |> request!()
    |> case do
      %{"instanceState" => %{"name" => status}} -> status
      nil -> nil
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
