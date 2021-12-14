defmodule Day14 do
  @type element :: String.t
  @type pair :: {element, element}
  @type insertions :: %{pair => element}
  @type polymer :: [element]
  @type input :: {polymer, insertions}

  @spec input(String.t) :: input
  defp input(filename) do
    [polymer, insertions] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    polymer = String.codepoints(polymer)

    insertions =
      insertions
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_insertion/1)
      |> Enum.into(%{})

    {polymer, insertions}
  end

  @spec parse_insertion(String.t) :: {pair, element}
  defp parse_insertion(str) do
    [pair, element] = String.split(str, " -> ", trim: true)
    [a, b] = String.codepoints(pair)
    {{a, b}, element}
  end

  @spec step(insertions, polymer, polymer) :: polymer
  defp step(insertions, polymer, new_polymer \\ [])

  defp step(_insertions, [x], new_polymer) do
    Enum.reverse([x | new_polymer])
  end

  defp step(insertions, [a, b | rest], new_polymer) do
    case insertions[{a, b}] do
      nil -> step(insertions, [b | rest], [a | new_polymer])
      x -> step(insertions, [b | rest], [x , a | new_polymer])
    end
  end

  def part1(filename \\ "input.txt") do
    {polymer, insertions} = input(filename)

    freqs =
      1..10
      |> Enum.reduce(polymer, fn _, acc -> step(insertions, acc) end)
      |> Enum.frequencies
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    List.last(freqs) - List.first(freqs)
  end

  ## Part 2 -- let's stream it

  defp step_stream(insertions, polymer_stream) do
    reducer = fn
      :halt, acc ->
        {[acc], nil}

      elt, acc ->
        case insertions[{acc, elt}] do
          nil -> {[acc], elt}
          x -> {[acc, x], elt}
        end
    end

    polymer_stream
    |> Stream.concat(:halt)
    |> Stream.transform(nil, reducer)
  end

  def part2(filename \\ "input.txt") do
    {polymer, insertions} = input(filename)

    freqs =
      1..40
      |> Enum.reduce(polymer, fn _, acc -> step_stream(insertions, acc) end)
      |> IO.inspect
      |> Enum.frequencies
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    List.last(freqs) - List.first(freqs)
  end
end
