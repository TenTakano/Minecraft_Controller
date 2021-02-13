defmodule MinecraftController.CommonCase do
  defmacro __using__(opts) do
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
end
