defmodule MinecraftController.RCON.PacketTest do
  use MinecraftController.CommonCase

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

    test "raise error for invalid format packet" do
      Enum.each([
        %{id: "a", type: :auth, payload: "password"},
        %{id: 1, type: :invalid, payload: "password"},
        %{id: 1, type: :auth, payload: String.duplicate("a", 4097)}
      ], fn invalid_command ->
        assert_raise ArgumentError, fn -> Packet.encode(invalid_command) end
      end)
    end
  end
end
