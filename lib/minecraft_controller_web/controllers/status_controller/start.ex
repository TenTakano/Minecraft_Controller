defmodule MinecraftControllerWeb.EC2Controller.Start do
  use MinecraftControllerWeb, :controller

  alias MinecraftController.Context.EC2

  def get(conn, _) do
    case EC2.target_instance_id() do
      nil ->
        json(conn, %{status: "nothing"})
      instance_id ->
        :ok = EC2.start_instance(instance_id)
        json(conn, %{instance_id: instance_id, status: "running"})
    end
  end
end
