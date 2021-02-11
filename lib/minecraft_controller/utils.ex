defmodule MinecraftController.Utils do
  @spec wait_milliseconds(number) :: :ok
  def wait_milliseconds(milliseconds) do
    :timer.sleep(milliseconds)
    :ok
  end
end
