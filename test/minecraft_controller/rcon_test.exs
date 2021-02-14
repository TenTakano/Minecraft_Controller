defmodule MinecraftController.RCONTest do
  use MinecraftController.CommonCase

  alias RCON.Client

  describe "get_player_list/0" do
    test "retruns members list" do
      Enum.each([
        {"There are 0 of a max of 20 players online: ", %{count: 0, limit: 20, members: []}},
        {"There are 2 of a max of 20 players online: user1 user2", %{count: 2, limit: 20, members: ["user1", "user2"]}}
      ], fn {input, expected} ->
        :meck.expect(Client, :send_command, fn _ -> {:ok, %{payload: input}} end)
        assert RCON.get_player_list() == {:ok, expected}
      end)
    end

    test "returns error if rcon connection error occurs" do
      error_res = {:error, :econnrefused}
      :meck.expect(Client, :send_command, fn _ -> error_res end)
      assert RCON.get_player_list() == error_res
    end
  end
end
