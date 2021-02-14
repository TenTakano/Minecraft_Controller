defmodule MinecraftController.RCON do
  alias __MODULE__.{Client, Packet}

  def get_player_list() do
    gen_command("list")
    |> Client.send_command()
    |> case do
      {:ok, %{payload: response_message}} ->
        res =
          ~r/There are (?<count>\d*) of a max of (?<limit>\d*) players online: (?<members>.*)/
          |> Regex.named_captures(response_message)
          |> Map.update!("members", fn
            "" -> []
            members -> String.split(members, "")
          end)
        {:ok, res}
      error ->
        error
    end
  end

  @spec gen_command(String.t) :: Packet.t
  defp gen_command(op) do
    Packet.encode(%{id: 2, type: :command, payload: op})
  end
end
