defmodule MinecraftController.RCON.Packet do
  @enforce_keys [:id, :type]
  defstruct [:id, :type, :payload]

  @terminate <<0, 0>>
  @payload_limit 4096
  @fixed_part_size 10

  @spec encode(map) :: binary
  def encode(packet) do
    with(
      type_code <- type_to_code(packet.type),
      {:ok, length} <- packet_length(packet.payload),
      header <-
        <<
          length :: 32-signed-integer-little,
          packet.id :: 32-signed-integer-little,
          type_code :: 32-signed-integer-little
        >>
    ) do
      header <> packet.payload <> @terminate
    else
      _ -> raise ArgumentError
    end
  end

  @spec type_to_code(atom) :: integer | nil
  defp type_to_code(:auth), do: 3
  defp type_to_code(:command), do: 2
  defp type_to_code(_), do: nil

  @spec packet_length(String.t) :: {:ok, integer} | :error
  defp packet_length(payload) do
    case byte_size(payload) do
      length when length <= @payload_limit -> {:ok, length + @fixed_part_size}
      _ -> :error
    end
  end
end
