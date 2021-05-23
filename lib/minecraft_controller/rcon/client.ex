defmodule MinecraftController.RCON.Client do
  alias MinecraftController.RCON.Packet

  @spec send_command(Packet.t()) :: Packet.t()
  def send_command(command) do
    config = load_config()

    case :gen_tcp.connect(String.to_charlist(config.host), config.port, [:binary, active: false]) do
      {:ok, socket} ->
        response = send_with_auth(socket, command, config.password)
        :ok = :gen_tcp.close(socket)
        response

      error ->
        error
    end
  end

  @spec send_with_auth(port, Packet.t(), String.t()) ::
          {:ok, Packet.t()} | {:error, :auth_failure}
  defp send_with_auth(socket, command, password) do
    case send_and_receive(socket, Packet.encode(%{id: 1, type: :auth, payload: password})) do
      %{type: :auth_response} ->
        {:ok, send_and_receive(socket, command)}

      _ ->
        {:error, :auth_failure}
    end
  end

  @spec send_and_receive(port, Packet.t()) :: Packet.t()
  defp send_and_receive(socket, packet) do
    :ok = :gen_tcp.send(socket, packet)
    {:ok, res} = :gen_tcp.recv(socket, 0)
    Packet.decode(res)
  end

  # TODO: revise to use private ip
  defp load_config() do
    %{public_ip: host} = MinecraftController.EC2.get_instance()

    Application.get_env(:minecraft_controller, __MODULE__)
    |> Map.new()
    |> Map.put(:host, host)
  end
end
