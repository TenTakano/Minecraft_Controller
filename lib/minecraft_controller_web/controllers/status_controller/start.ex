defmodule MinecraftControllerWeb.EC2Controller.Start do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Context.EC2

  @retry_interval_milliseconds 1000
  @retry_times_limit 10

  def get(conn, _) do
    with(
      {:ok, instance_id} <- EC2.target_instance_id(),
      :ok <- EC2.start_instance(instance_id),
      :ok <- wait_for_instance_started(instance_id)
    )
    do
      res_body = %{
        instance_id: instance_id,
        status: "running"
      }
      json(conn, res_body)
    else
      {:error, :not_found} -> conn |> put_status(400) |> json(%{message: "Instance not found"})
      :timeout -> conn |> put_status(409) |> json(%{message: "Something error occurs on AWS"})
    end
  end

  @spec wait_for_instance_started(String.t) :: :ok | :timeout
  defp wait_for_instance_started(instance_id), do: wait_for_instance_started(instance_id, 0)

  @spec wait_for_instance_started(String.t, number) :: :ok | :timeout
  defp wait_for_instance_started(instance_id, retry_times) do
    case {EC2.get_instance_status(instance_id), retry_times} do
      {"running", _} -> :ok
      {_, retry_times} when retry_times < @retry_times_limit ->
        :timer.sleep(@retry_interval_milliseconds)
        wait_for_instance_started(instance_id)
      _ ->
        :timeout
    end
  end
end
