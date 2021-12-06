defmodule Day06 do
  @input "input.txt"
         |> File.read!()

  defp parse_input(str) do
    str
    |> String.split(",")
    |> Enum.map(&to_int/1)
  end

  defp to_int(x) do
    {i, ""} = Integer.parse(x)
    i
  end

  defp next_day(fishes) do
    Enum.flat_map(fishes, fn
      0 -> [6, 8]
      fish -> [fish - 1]
    end)
  end

  def part1 do
    fishes = parse_input(@input)

    fishes80 =
      Enum.reduce(1..80, fishes, fn _i, acc ->
        next_day(acc)
      end)

    Enum.count(fishes80)
  end

  defp how_many_after(fish, days) do
    state = %{
      spawns: %{fish => 1},
      count: 1
    }

    %{count: count} =
      Enum.reduce(0..(days - 1), state, fn day, state ->
        case state.spawns[day] do
          nil ->
            state

          n ->
            spawn7 = state.spawns[day + 7] || 0
            spawn9 = state.spawns[day + 9] || 0

            spawns =
              state.spawns
              |> Map.put(day + 7, spawn7 + n)
              |> Map.put(day + 9, spawn9 + n)

            %{state | spawns: spawns, count: state.count + n}
        end
      end)

    count
  end

  def part1_alt do
    @input
    |> parse_input()
    |> Enum.map(fn fish -> how_many_after(fish, 80) end)
    |> Enum.reduce(0, fn a, b -> a + b end)
  end

  def part2 do
    @input
    |> parse_input()
    |> Enum.map(fn fish -> how_many_after(fish, 256) end)
    |> Enum.reduce(0, fn a, b -> a + b end)
  end
end
