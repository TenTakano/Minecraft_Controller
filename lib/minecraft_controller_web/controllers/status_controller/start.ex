defmodule MinecraftControllerWeb.EC2Controller.Start do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.EC2
  alias MinecraftController.Utils

  @retry_interval_milliseconds 5000
  @retry_times_limit 10

  def get(conn, _) do
    with(
      :ok <- EC2.start_instance(),
      ip when ip != :timeout <- wait_for_instance_started()
    )
    do
      json(conn, %{ip: ip})
    else
      {:error, :not_found} -> error_json(conn, Error.InstanceNotFound)
      :timeout -> error_json(conn, Error.AwsError)
    end
  end

  @spec wait_for_instance_started() :: String.t | :timeout
  defp wait_for_instance_started(), do: wait_for_instance_started(0)

  @spec wait_for_instance_started(number) :: String.t | :timeout
  defp wait_for_instance_started(retry_times) do
    case {EC2.get_instance(), retry_times} do
      {{:ok, %{status: "running", public_ip: ip}}, _} -> ip
      {_, retry_times} when retry_times < @retry_times_limit ->
        Utils.wait_milliseconds(@retry_interval_milliseconds)
        wait_for_instance_started(retry_times + 1)
      _ ->
        :timeout
    end
  end
end
