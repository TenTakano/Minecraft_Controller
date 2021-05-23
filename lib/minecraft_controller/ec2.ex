defmodule MinecraftController.EC2 do
  alias ExAws.EC2

  @spec target_instance_id() :: String.t()
  def target_instance_id() do
    Application.get_env(:minecraft_controller, __MODULE__)
    |> Keyword.fetch!(:target_instance_id)
  end

  @spec get_instance() :: {:ok, map} | {:error, :instance_not_found}
  def get_instance() do
    %{status_code: 200, body: body} =
      EC2.describe_instances(filters: [{"instance-id", [target_instance_id()]}])
      |> ExAws.request!()

    XmlToMap.naive_map(body)
    |> get_in(["DescribeInstancesResponse", "reservationSet"])
    |> case do
      nil ->
        {:error, :instance_not_found}

      %{"item" => %{"instancesSet" => %{"item" => instance}}} ->
        attributes = %{
          status: get_in(instance, ["instanceState", "name"]),
          public_ip: get_in(instance, ["networkInterfaceSet", "item", "association", "publicIp"]),
          private_ip: instance["privateIpAddress"]
        }

        {:ok, attributes}
    end
  end

  @spec start_instance() :: :ok
  def start_instance() do
    %{status_code: 200} =
      target_instance_id()
      |> EC2.start_instances()
      |> ExAws.request!()

    :ok
  end

  @spec stop_instance() :: :ok
  def stop_instance() do
    %{status_code: 200} =
      target_instance_id()
      |> EC2.stop_instances()
      |> ExAws.request!()

    :ok
  end
end
