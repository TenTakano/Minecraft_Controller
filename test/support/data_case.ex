defmodule MinecraftController.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExAws.Dynamo

      import MinecraftController.DataCase
    end
  end

  setup do
    on_exit(&:meck.unload/0)
    :ok
  end
end
