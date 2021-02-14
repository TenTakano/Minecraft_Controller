defmodule MinecraftController.RCON.Packet do
  @enforce_keys [:id, :type]
  defstruct [:id, :type, :payload]

  @terminate <<0, 0>>
  @payload_limit 4096
  @fixed_part_size 10
  @length_part_size 4

  @spec encode(map) :: binary
  def encode(packet) do
    with(
      {:ok, type_code} <- type_to_code(packet.type),
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

  @spec decode(binary) :: map
  def decode(bytes) do
    with(
      {:ok, payload_part_size} <- payload_size(bytes),
      <<
        length :: 32-signed-integer-little,
        id :: 32-signed-integer-little,
        type_code :: 32-signed-integer-little,
        payload :: binary-size(payload_part_size)
      >> <> @terminate <- bytes,
      true <- length == payload_part_size + @fixed_part_size,
      true <- length <= @payload_limit,
      {:ok, type} <- code_to_type(type_code)
    ) do
      %{id: id, type: type, payload: payload}
    else
      _ -> raise ArgumentError
    end
  end

  @spec type_to_code(atom) :: {:ok, non_neg_integer} | :error
  defp type_to_code(:auth), do: {:ok, 3}
  defp type_to_code(:command), do: {:ok, 2}
  defp type_to_code(_), do: :error

  @spec code_to_type(non_neg_integer) :: {:ok, atom} | :error
  defp code_to_type(2), do: {:ok, :auth_response}
  defp code_to_type(0), do: {:ok, :command_response}
  defp code_to_type(_), do: :error

  @spec packet_length(String.t) :: {:ok, non_neg_integer} | :error
  defp packet_length(payload) do
    case byte_size(payload) do
      length when length <= @payload_limit -> {:ok, length + @fixed_part_size}
      _ -> :error
    end
  end

  @spec payload_size(binary) :: {:ok, non_neg_integer} | :error
  defp payload_size(bytes) do
    total_size = byte_size(bytes) - @fixed_part_size - @length_part_size
    if total_size >= 0 do
      {:ok, total_size}
    else
      :error
    end
  end
end
