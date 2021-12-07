defmodule Day07 do
  @input "input.txt" |> File.read!() |> String.trim()

  ## A crab is represented by its horizontal position
  @type crab :: integer

  defp get_crabs(input) do
    @input
    |> String.split(",")
    |> Enum.map(&to_int/1)
  end

  defp to_int(x) do
    {i, ""} = Integer.parse(x)
    i
  end

  def part1 do
    [first | _rest] = crabs = get_crabs()

    min_crab = Enum.reduce(crabs, first, fn a, b -> min(a, b) end)
    max_crab = Enum.reduce(crabs, first, fn a, b -> max(a, b) end)

    starting_state = {cost1(crabs, min_crab), min_crab}

    {min_cost, _position} =
      Enum.reduce(min_crab..max_crab, starting_state, fn position, {cost, costpos} ->
        case cost1(crabs, position) do
          c when c < cost -> {c, position}
          _ -> {cost, costpos}
        end
      end)

    min_cost
  end

  defp cost1(crabs, position) do
    Enum.reduce(crabs, 0, fn crab, cost -> cost + abs(crab - position) end)
  end

  def part2 do
    [first | _rest] = crabs = get_crabs()

    min_crab = Enum.reduce(crabs, first, fn a, b -> min(a, b) end)
    max_crab = Enum.reduce(crabs, first, fn a, b -> max(a, b) end)

    starting_state = {cost2(crabs, min_crab), min_crab}

    {min_cost, _position} =
      Enum.reduce(min_crab..max_crab, starting_state, fn position, {cost, costpos} ->
        case cost2(crabs, position) do
          c when c < cost -> {c, position}
          _ -> {cost, costpos}
        end
      end)

    min_cost
  end

  defp cost2(crabs, position) do
    Enum.reduce(crabs, 0, fn crab, cost -> cost + tri_sum(abs(crab - position)) end)
  end

  defp tri_sum(n), do: round(n * (n + 1) / 2)
end
