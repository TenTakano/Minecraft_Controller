defmodule Mix.Tasks.DropDb do
  use Mix.Task

  alias ExAws.Dynamo

  def run(_) do
    Application.ensure_all_started(:hackney)
    :ok = drop_all_tables()
  end

  @spec drop_all_tables() :: :ok
  def drop_all_tables() do
    %{"TableNames" => table_names} = Dynamo.list_tables() |> ExAws.request!()
    Enum.each(table_names, fn table ->
      {:ok, _} = Dynamo.delete_table(table) |> ExAws.request()
    end)
  end
end
