defmodule MinecraftController.Context.EC2 do
  alias ExAws.EC2

  @target_tag %{"key" => "controller", "value" => "minecraft-controller"}

  @spec target_instance_id() :: String.t | nil
  def target_instance_id() do
    try do
      EC2.describe_instances()
      |> request!()
      |> get_in(["DescribeInstancesResponse", "reservationSet", "item"])
      |> Enum.find(fn %{"tagSet" => %{"item" => tags}} ->
        cond do
          is_list(tags) -> Enum.any?(tags, &(&1 == @target_tag))
          is_map(tags) -> tags == @target_tag
        end
      end)
      |> case do
        %{"instanceId" => instance_id} -> instance_id
        _ -> nil
      end
    rescue
      _ -> nil
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
    XmlToMap.naive_map(body)
  end
end
