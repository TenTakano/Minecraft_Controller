defmodule MinecraftController.CommonCase do
  use ExUnit.CaseTemplate

  alias Mix.Tasks.{CreateDb, DropDb}

  using opts do
    %Macro.Env{module: test_module} = __CALLER__

    target_module =
      test_module
      |> Atom.to_string()
      |> String.replace(~r/Test$/, "")
      |> List.wrap()
      |> Module.safe_concat()

    quote do
      use ExUnit.Case, unquote(opts)
      alias unquote(target_module)
    end
  end

  setup do
    :ok = DropDb.drop_all_tables()
    :ok = CreateDb.create_tables()

    on_exit(&:meck.unload/0)
    :ok
  end
end
