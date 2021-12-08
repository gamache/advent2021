defmodule Day08 do
  ## A digit is a list of 2-7 characters [a-g]
  @type digit :: [String.t()]

  ## First item is 10 pattern digits, second item is 4 output digits
  @type entry :: {[digit], [digit]}

  @digits %{
    0 => MapSet.new(~w(a b c e f g)),
    1 => MapSet.new(~w(c f)),
    2 => MapSet.new(~w(a c d e g)),
    3 => MapSet.new(~w(a c d f g)),
    4 => MapSet.new(~w(b c d f)),
    5 => MapSet.new(~w(a b d f g)),
    6 => MapSet.new(~w(a b d e f g)),
    7 => MapSet.new(~w(a c f)),
    8 => MapSet.new(~w(a b c d e f g)),
    9 => MapSet.new(~w(a b c d f g))
  }

  @spec entries(String.t()) :: [entry]
  defp entries(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&to_entry/1)
  end

  @spec to_entry(String.t()) :: entry
  defp to_entry(line) do
    [pattern, output] = String.split(line, " | ")
    patterns = pattern |> String.split(" ") |> Enum.map(&String.codepoints/1)
    outputs = output |> String.split(" ") |> Enum.map(&String.codepoints/1)
    {patterns, outputs}
  end

  def part1(filename \\ "input.txt") do
    filename
    |> entries()
    |> Enum.flat_map(fn {_patterns, outputs} -> outputs end)
    |> Enum.filter(fn digit -> Enum.count(digit) in [2, 3, 4, 7] end)
    |> Enum.count()
  end

  defp mappings({patterns, _outputs} = _entry) do
    ## a can be found by looking at 1 (cf) and 7 (acf)

    [cf] = Enum.filter(patterns, fn p -> Enum.count(p) == 2 end)
    [acf] = Enum.filter(patterns, fn p -> Enum.count(p) == 3 end)
    [a] = Enum.filter(acf, fn x -> !(x in cf) end)

    ## Each five-segment digit contains adg. a is known.
    ## 4 consists of bcdf. cf can be obtained from 1, leaving bd.
    ## These two facts can be combined to determine d, then b, then g.

    [five1, five2, five3] =
      patterns
      |> Enum.filter(fn p -> Enum.count(p) == 5 end)
      |> Enum.map(&MapSet.new/1)

    adg = five1 |> MapSet.intersection(five2) |> MapSet.intersection(five3) |> MapSet.to_list()
    dg = Enum.filter(adg, fn x -> x != a end)

    [bcdf] = Enum.filter(patterns, fn p -> Enum.count(p) == 4 end)
    bd = Enum.filter(bcdf, fn x -> !(x in cf) end)

    [d] = MapSet.new(bd) |> MapSet.intersection(MapSet.new(dg)) |> MapSet.to_list()
    [b] = Enum.filter(bd, fn x -> x != d end)
    [g] = Enum.filter(dg, fn x -> x != d end)

    ## We know abdg, which occurs in only one five-segment: abdfg. Find f.

    [abdfg] =
      Enum.filter(patterns, fn p -> Enum.count(p) == 5 && a in p && b in p && d in p && g in p end)

    [f] = Enum.filter(abdfg, fn x -> !(x in [a, b, d, g]) end)

    ## Find c by doing the same thing with acdfg.

    [acdfg] =
      Enum.filter(patterns, fn p ->
        Enum.count(p) == 5 && a in p && d in p && f in p && g in p && !(b in p)
      end)

    [c] = Enum.filter(acdfg, fn x -> !(x in [a, d, f, g]) end)

    ## Finally, we can get e from abcdefg.

    [abcdefg] = Enum.filter(patterns, fn p -> Enum.count(p) == 7 end)
    [e] = Enum.filter(abcdefg, fn x -> !(x in [a, b, c, d, f, g]) end)

    %{
      a => "a",
      b => "b",
      c => "c",
      d => "d",
      e => "e",
      f => "f",
      g => "g"
    }
  end

  defp output_value(entry) do
    output_value(entry, mappings(entry))
  end

  defp output_value({_patterns, outputs}, mappings) do
    [m, c, x, i] =
      outputs
      |> Enum.map(fn digit -> apply_mappings(digit, mappings) end)
      |> Enum.map(&numeral/1)

    m * 1000 + c * 100 + x * 10 + i
  end

  defp apply_mappings(digit, mappings) do
    Enum.map(digit, fn x -> mappings[x] end)
  end

  defp numeral(digit) do
    digit_set = MapSet.new(digit)
    [{numeral, _digit}] = Enum.filter(@digits, fn {_n, d} -> MapSet.equal?(d, digit_set) end)
    numeral
  end

  def part2(filename \\ "input.txt") do
    filename
    |> entries()
    |> Enum.map(&output_value/1)
    |> Enum.sum()
  end
end
