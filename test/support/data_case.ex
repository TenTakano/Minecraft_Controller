defmodule MinecraftController.DataCase do
  use ExUnit.CaseTemplate

  alias Mix.Tasks.{CreateDb, DropDb}

  using do
    quote do
      use MinecraftController.CommonCase

      alias ExAws.Dynamo

      import MinecraftController.DataCase
    end
  end

  setup do
    :ok = DropDb.drop_all_tables()
    :ok = CreateDb.create_tables()

    on_exit(&:meck.unload/0)
    :ok
  end
end
