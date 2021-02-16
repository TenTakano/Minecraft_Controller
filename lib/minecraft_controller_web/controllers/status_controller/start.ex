defmodule MinecraftControllerWeb.EC2Controller.Start do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.EC2
  alias MinecraftController.Utils

  @retry_interval_milliseconds 1000
  @retry_times_limit 10

  def get(conn, _) do
    with(
      {:ok, instance_id} <- EC2.target_instance_id(),
      :ok <- EC2.start_instance(instance_id),
      ip <- wait_for_instance_started(instance_id)
    )
    do
      json(conn, %{ip: ip})
    else
      {:error, :not_found} -> error_json(conn, Error.InstanceNotFound)
      :timeout -> error_json(conn, Error.AwsError)
    end
  end

  @spec wait_for_instance_started(String.t) :: String.t | :timeout
  defp wait_for_instance_started(instance_id), do: wait_for_instance_started(instance_id, 0)

  @spec wait_for_instance_started(String.t, number) :: String.t | :timeout
  defp wait_for_instance_started(instance_id, retry_times) do
    case {EC2.get_instance_status(instance_id), retry_times} do
      {%{status: "running", ip: ip}, _} -> ip
      {_, retry_times} when retry_times < @retry_times_limit ->
        Utils.wait_milliseconds(@retry_interval_milliseconds)
        wait_for_instance_started(instance_id, retry_times + 1)
      _ ->
        :timeout
    end
  end
end
