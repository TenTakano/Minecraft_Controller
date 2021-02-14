defmodule MinecraftController.RCON.Client do
  alias MinecraftController.RCON.Packet

  @config if Mix.env() == :test, do: [], else: Application.get_env(:minecraft_controller, __MODULE__)

  @spec send_command(Packet.t) :: Packet.t
  def send_command(command) do
    [host, port, password] = Enum.map([:host, :port, :pass], &Keyword.fetch!(@config, &1))
    case :gen_tcp.connect(String.to_charlist(host), port, [:binary, active: false]) do
      {:ok, socket} ->
        response = send_with_auth(socket, command, password)
        :ok = :gen_tcp.close(socket)
        response
      error ->
        error
    end
  end

  @spec send_with_auth(port, Packet.t, String.t) :: {:ok, Packet.t} | {:error, :auth_failure}
  defp send_with_auth(socket, command, password) do
    case send_and_receive(socket, Packet.encode(%{id: 1, type: :auth, payload: password})) do
      %{type: :auth_response} ->
        {:ok, send_and_receive(socket, command)}
      _ ->
        {:error, :auth_failure}
    end
  end

  @spec send_and_receive(port, Packet.t) :: Packet.t
  defp send_and_receive(socket, packet) do
    :ok = :gen_tcp.send(socket, packet)
    {:ok, res} = :gen_tcp.recv(socket, 0)
    Packet.decode(res)
  end  
end
