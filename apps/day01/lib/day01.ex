defmodule Day01 do
  @input "input.txt"
         |> File.read!()
         |> String.trim_trailing()
         |> String.split("\n")
         |> Enum.map(fn x ->
           {i, ""} = Integer.parse(x)
           i
         end)

  def part1 do
    count_increases(@input, 0)
  end

  defp count_increases([first | [second | _] = rest], count) do
    if second > first do
      count_increases(rest, count + 1)
    else
      count_increases(rest, count)
    end
  end

  defp count_increases(_, count), do: count

  def part2 do
    window_sums(@input, [])
    |> count_increases(0)
  end

  defp window_sums([a, b, c], sums) do
    Enum.reverse([a + b + c | sums])
  end

  defp window_sums([a | [b, c | _] = rest], sums) do
    window_sums(rest, [a + b + c | sums])
  end
end
