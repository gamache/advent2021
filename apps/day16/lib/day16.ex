defmodule Day16 do
  @type packet :: %{
          version: non_neg_integer,
          type: non_neg_integer,
          value: non_neg_integer | nil,
          packets: [packet]
        }

  @spec bitstring(String.t()) :: bitstring
  defp bitstring(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> :binary.decode_hex()
  end

  ## Breaks a bitstring into zero or more packets.
  @spec packets(bitstring, [packet]) :: [packet]
  defp packets(bitstring, packets \\ [])

  defp packets("", packets) do
    packets |> Enum.reverse() |> Enum.filter(fn p -> p end)
  end

  defp packets(bitstring, packets) do
    {packet, rest} = packet(bitstring)
    packets(rest, [packet | packets])
  end

  ## Returns the next packet (which may have subpackets), and the rest of the input.
  @type packet(bitstring) :: {packet | nil, bitstring}
  defp packet(bitstring)

  defp packet(<<version::3, 4::3, rest::bits>>) do
    {literal, rest} = literal(rest)
    packet = %{version: version, type: 4, value: btoi(literal), packets: []}
    {packet, rest}
  end

  defp packet(<<version::3, type::3, 0::1, len::15, rest::bits>>) do
    <<data::bits-size(len), rest::bits>> = rest
    packet = %{version: version, type: type, packets: packets(data), value: nil}
    {packet, rest}
  end

  defp packet(<<version::3, type::3, 1::1, count::11, rest::bits>>) do
    {packets, rest} = take_packets(rest, count)
    packet = %{version: version, type: type, packets: packets, value: nil}
    {packet, rest}
  end

  defp packet(<<0::1, rest::bits>>), do: packet(rest)

  defp packet(""), do: {nil, ""}

  ## Returns a literal value encoded in a packet, and the rest of the input.
  @spec literal(bitstring, bitstring) :: {bitstring, bitstring}
  defp literal(bitstring, acc \\ "")

  defp literal(<<1::1, data::bits-size(4), rest::bitstring>>, acc) do
    literal(rest, <<acc::bits, data::bits>>)
  end

  defp literal(<<0::1, data::bits-size(4), rest::bitstring>>, acc) do
    {<<acc::bits, data::bits>>, rest}
  end

  ## Bitstring to integer
  @spec btoi(bitstring) :: non_neg_integer
  defp btoi(bitstring) do
    pad_size = 8 - rem(:erlang.bit_size(bitstring), 8)
    :binary.decode_unsigned(<<0::size(pad_size), bitstring::bits>>)
  end

  ## Returns the next `count` packets, and the rest of the input.
  @spec take_packets(bitstring, non_neg_integer, [packet]) :: {[packet], bitstring}
  defp take_packets(bitstring, count, packets \\ [])

  defp take_packets(rest, 0, packets) do
    {Enum.reverse(packets), rest}
  end

  defp take_packets(bitstring, count, packets) do
    {packet, rest} = packet(bitstring)
    take_packets(rest, count - 1, [packet | packets])
  end

  ## Un-nests subpackets, returning a one-level list of packets.
  defp flatten_packets(packets) do
    Enum.flat_map(packets, fn packet ->
      case packet.packets do
        [] -> [packet]
        ps -> [packet | flatten_packets(ps)]
      end
    end)
  end

  def part1(filename \\ "input.txt") do
    filename
    |> bitstring()
    |> packets()
    |> flatten_packets()
    |> Enum.map(fn p -> p.version end)
    |> Enum.sum()
  end

  ## Returns the value for this packet, computing subpacket values as necessary.
  @spec eval(packet) :: integer
  defp eval(%{type: 0} = packet) do
    packet.packets
    |> Enum.map(&eval/1)
    |> Enum.reduce(0, &Kernel.+/2)
  end

  defp eval(%{type: 1} = packet) do
    packet.packets
    |> Enum.map(&eval/1)
    |> Enum.reduce(1, &Kernel.*/2)
  end

  defp eval(%{type: 2} = packet) do
    packet.packets
    |> Enum.map(&eval/1)
    |> Enum.min()
  end

  defp eval(%{type: 3} = packet) do
    packet.packets
    |> Enum.map(&eval/1)
    |> Enum.max()
  end

  defp eval(%{type: 4} = packet) do
    packet.value
  end

  defp eval(%{type: 5} = packet) do
    [a, b] = packet.packets |> Enum.map(&eval/1)
    if a > b, do: 1, else: 0
  end

  defp eval(%{type: 6} = packet) do
    [a, b] = packet.packets |> Enum.map(&eval/1)
    if a < b, do: 1, else: 0
  end

  defp eval(%{type: 7} = packet) do
    [a, b] = packet.packets |> Enum.map(&eval/1)
    if a == b, do: 1, else: 0
  end

  def part2(filename \\ "input.txt") do
    filename
    |> bitstring()
    |> packets()
    |> List.first()
    |> eval()
  end
end
