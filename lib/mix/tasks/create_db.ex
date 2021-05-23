defmodule Mix.Tasks.CreateDb do
  use Mix.Task

  # {table name, read capacity, write capacity}
  @tables [{"Users", 1, 1}]

  def run(_) do
    Application.ensure_all_started(:hackney)
    :ok = create_tables()
  end

  @spec create_tables() :: :ok
  def create_tables() do
    Enum.each(@tables, fn {table_name, read_capacity, write_capacity} ->
      ExAws.Dynamo.create_table(table_name, :id, %{id: :string}, read_capacity, write_capacity)
      |> ExAws.request!()
    end)
  end
end
