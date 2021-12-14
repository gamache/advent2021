defmodule Day14 do
  @type element :: String.t() | :pad
  @type pair :: {element, element}
  @type insertions :: %{pair => element}
  @type polymer :: [element]
  @type input :: {polymer, insertions}

  @spec input(String.t()) :: input
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

  @spec parse_insertion(String.t()) :: {pair, element}
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
      x -> step(insertions, [b | rest], [x, a | new_polymer])
    end
  end

  def part1(filename \\ "input.txt") do
    {polymer, insertions} = input(filename)

    freqs =
      1..10
      |> Enum.reduce(polymer, fn _, acc -> step(insertions, acc) end)
      |> Enum.frequencies()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    List.last(freqs) - List.first(freqs)
  end

  ## This approach does not work so well for part 2.
  ## Let's keep track of pairs in a map instead.

  @type polymer_pairs :: %{pair => non_neg_integer}

  @spec polymer_pairs(polymer) :: polymer_pairs
  defp polymer_pairs(polymer) do
    ## We must pad the polymer in order to get correct frequencies
    polymer_pairs([:pad] ++ polymer ++ [:pad], %{})
  end

  defp polymer_pairs([_], pairs), do: pairs

  defp polymer_pairs([a, b | rest], pairs) do
    polymer_pairs([b | rest], increment(pairs, {a, b}))
  end

  defp increment(map, key, addend \\ 1) do
    count = map[key] || 0
    Map.put(map, key, count + addend)
  end

  @spec step_pairs(polymer_pairs, insertions) :: polymer_pairs
  defp step_pairs(polymer_pairs, insertions) do
    Enum.reduce(polymer_pairs, %{}, fn {{a, b} = pair, count}, acc ->
      case insertions[pair] do
        nil -> increment(acc, pair, count)
        x -> acc |> increment({a, x}, count) |> increment({x, b}, count)
      end
    end)
  end

  @spec frequencies(polymer_pairs) :: %{element => non_neg_integer}
  defp frequencies(polymer_pairs) do
    polymer_pairs
    |> Enum.to_list()
    |> frequencies(%{})
  end

  defp frequencies([], frequencies) do
    frequencies
    |> Map.delete(:pad)
    |> Enum.map(fn {k, v} -> {k, div(v, 2)} end)
    |> Enum.into(%{})
  end

  defp frequencies([{{a, b}, count} | rest], frequencies) do
    freqs =
      frequencies
      |> increment(a, count)
      |> increment(b, count)

    frequencies(rest, freqs)
  end

  def part2(filename \\ "input.txt") do
    {polymer, insertions} = input(filename)

    polymer_pairs = polymer_pairs(polymer)

    freqs =
      1..40
      |> Enum.reduce(polymer_pairs, fn _, acc ->
        step_pairs(acc, insertions)
      end)
      |> frequencies()
      |> Enum.map(fn {_k, v} -> v end)
      |> Enum.sort()

    List.last(freqs) - List.first(freqs)
  end
end
