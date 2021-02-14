defmodule Mix.Tasks.CheckAndStopServer do
  use Mix.Task

  alias MinecraftController.RCON

  def run(_) do
    case RCON.get_player_list() do
      {:ok, %{"count" => count}} when count > 0 ->
        :do_something
      _ ->
        :ok
    end
  end
end
