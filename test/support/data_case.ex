defmodule MinecraftController.DataCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use MinecraftController.CommonCase

      alias ExAws.Dynamo

      import MinecraftController.DataCase
    end
  end
end
