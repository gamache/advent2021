defmodule Day03 do
  @input "input.txt"
         |> File.read!()
         |> String.trim_trailing()
         |> String.split("\n")

  def part1 do
    counts = count(@input, %{})

    gamma_rate(counts) * epsilon_rate(counts)
  end

  ## counts is like: %{ index => %{ char => count } }
  defp count([], counts), do: counts

  defp count([str | rest], counts) do
    count(rest, count1(str, counts))
  end

  defp count1(str, counts) do
    str
    |> String.codepoints()
    |> Enum.with_index()
    |> Enum.reduce(counts, fn {char, index}, counts ->
      index_counts = counts[index] || %{}
      count = index_counts[char] || 0
      new_index_counts = Map.put(index_counts, char, count + 1)
      Map.put(counts, index, new_index_counts)
    end)
  end

  defp gamma_rate(counts) do
    {gamma, ""} =
      0..(map_size(counts) - 1)
      |> Enum.map(fn index ->
        [{char, _} | _] = Enum.sort_by(counts[index], fn {_char, count} -> 0 - count end)
        char
      end)
      |> Enum.join("")
      |> Integer.parse(2)

    gamma
  end

  defp epsilon_rate(counts) do
    {epsilon, ""} =
      0..(map_size(counts) - 1)
      |> Enum.map(fn index ->
        [{char, _} | _] = Enum.sort_by(counts[index], fn {_char, count} -> count end)
        char
      end)
      |> Enum.join("")
      |> Integer.parse(2)

    epsilon
  end

  def part2 do
    o2_rating(@input, 0) * co2_rating(@input, 0)
  end

  defp o2_rating([bitstring], _position) do
    {i, ""} = Integer.parse(bitstring, 2)
    i
  end

  ## returns a list of {char, count}, least common first
  defp char_counts(bitstrings, position) do
    bitstrings
    |> Enum.map(fn str -> String.slice(str, position, 1) end)
    |> Enum.reduce(%{}, fn char, counts ->
      count = counts[char] || 0
      Map.put(counts, char, count + 1)
    end)
    |> Enum.sort_by(fn {char, count} -> {count, char} end)
  end

  defp o2_rating(bitstrings, position) do
    ## find most common char in given position
    [{char, _count} | _] =
      char_counts(bitstrings, position)
      |> Enum.reverse()

    bitstrings
    |> Enum.filter(fn str -> String.slice(str, position, 1) == char end)
    |> o2_rating(position + 1)
  end

  defp co2_rating([bitstring], _position) do
    {i, ""} = Integer.parse(bitstring, 2)
    i
  end

  defp co2_rating(bitstrings, position) do
    ## find least common char in given position
    [{char, _count} | _] = char_counts(bitstrings, position)

    bitstrings
    |> Enum.filter(fn str -> String.slice(str, position, 1) == char end)
    |> co2_rating(position + 1)
  end
end
