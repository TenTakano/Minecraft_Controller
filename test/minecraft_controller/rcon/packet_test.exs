defmodule MinecraftController.RCON.PacketTest do
  use ExUnit.Case

  alias MinecraftController.RCON.Packet

  describe "encode/1" do
    test "encodes login command" do
      Enum.each([
        {
          %{id: 1, type: :auth, payload: "password"},
          <<18, 0, 0, 0, 1, 0, 0, 0, 3, 0, 0, 0, 112, 97, 115, 115, 119, 111, 114, 100, 0, 0>>
        },
        {
          %{id: 2, type: :command, payload: "list"},
          <<14, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 108, 105, 115, 116, 0, 0>>
        }
      ], fn {command, expected} ->
        assert Packet.encode(command) == expected
      end)
    end
  end
end
