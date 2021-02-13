defmodule MinecraftController.RCON do
  defmodule Packet do
    @enforce_keys [:id, :type]
    defstruct [:id, :type, :payload]

    @terminate <<0, 0>>
    @fixed_part_size 10
    @flexible_part_size_limit 4096 - @fixed_part_size

    @spec encode(map) :: binary
    def encode(packet) do
      with(
        type_code <- type_to_code(packet.type),
        flexible_part_size when flexible_part_size <= @flexible_part_size_limit <- byte_size(packet.payload),
        length = flexible_part_size + @fixed_part_size,
        header <-
          <<
            length :: 32-signed-integer-little,
            packet.id :: 32-signed-integer-little,
            type_code :: 32-signed-integer-little
          >>
      ) do
        header <> packet.payload <> @terminate
      end
    end

    @spec type_to_code(atom) :: integer | nil
    defp type_to_code(:login), do: 3
    defp type_to_code(:command), do: 2
    defp type_to_code(_), do: nil
  end

  # def connect() do
  #   %{host: host, port: port, pass: pass} =
  #     Application.get_env(:minecraft_controller, __MODULE__) |> Map.new()

  #   {:ok, socket} = :gen_tcp.connect(host, port, [:binary, active: :false])
  # end
end
