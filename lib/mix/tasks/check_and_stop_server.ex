defmodule Mix.Tasks.CheckAndStopServer do
  use Mix.Task

  alias MinecraftController.RCON
  alias MinecraftController.EC2

  def run(_) do
    with(
      {:ok, player_list} <- RCON.get_player_list(),
      true <- is_able_to_shutdown(player_list),
      {:ok, _} <- RCON.stop_server()
    ) do
      EC2.stop_instance()
    else
      false -> :ok
    end
  end

  @spec is_able_to_shutdown(map) :: boolean
  defp is_able_to_shutdown(%{count: 0}), do: true
  defp is_able_to_shutdown(_), do: false
end
