defmodule MinecraftController.RCON do
  alias __MODULE__.{Client, Packet}

  @spec get_player_list() :: {:ok, map} | {:error, atom}
  def get_player_list() do
    gen_command("list")
    |> Client.send_command()
    |> case do
      {:ok, %{payload: response_message}} ->
        res =
          ~r/There are (?<count>\d*) of a max of (?<limit>\d*) players online: (?<members>.*)/
          |> Regex.named_captures(response_message)
          |> Enum.into(%{}, fn
            {"members", ""} -> {:members, []}
            {"members", members} -> {:members, String.split(members, " ")}
            {key, value} -> {String.to_atom(key), String.to_integer(value)}
          end)
        {:ok, res}
      error ->
        error
    end
  end

  @spec stop_server() :: {:ok, Packet.t} | {:error, atom}
  def stop_server() do
    gen_command("stop")
    |> Client.send_command()
  end

  @spec gen_command(String.t) :: Packet.t
  defp gen_command(op) do
    Packet.encode(%{id: 2, type: :command, payload: op})
  end
end
