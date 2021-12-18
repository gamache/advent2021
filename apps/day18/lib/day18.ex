defmodule Day18 do
  @type pairs :: String.t()

  @doc ~S"""
  Explodes once.

  iex> Day18.explode("[[[[[9,8],1],2],3],4]")
  "[[[[0,9],2],3],4]"

  iex> Day18.explode("[7,[6,[5,[4,[3,2]]]]]")
  "[7,[6,[5,[7,0]]]]"

  iex> Day18.explode("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
  "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]"
  """
  def explode(pairs, i \\ 0, depth \\ 0) do
    {past, rest} = String.split_at(pairs, i)

    case rest do
      "" ->
        pairs

      "[" <> _ ->
        if depth >= 4, do: do_explode(past, rest), else: explode(pairs, i + 1, depth + 1)

      "]" <> _ ->
        explode(pairs, i + 1, depth - 1)

      _ ->
        explode(pairs, i + 1, depth)
    end
  end

  ## past is like "[[[[", rest is like "[1,2]]]]]"
  defp do_explode(past, rest) do
    {left, right, rest} = first_pair(rest)
    past = explode_left(past, left)
    rest = explode_right(rest, right)
    past <> "0" <> rest
  end

  @first_pair_re ~r/^ \[ (\d+) , (\d+) \] (.+)/x

  @doc ~S"""
  iex> Day18.first_pair("[1,2]]]]]")
  {1, 2, "]]]]"}
  """
  def first_pair(str) do
    [_, a, b, rest] = Regex.run(@first_pair_re, str)
    {String.to_integer(a), String.to_integer(b), rest}
  end

  @explode_left_re ~r/(\d+) ([^\d]+) $/x

  @doc ~S"""
  iex> Day18.explode_left("[7,[6,[5,[4,", 3)
  "[7,[6,[5,[7,"
  """
  def explode_left(str, value) do
    Regex.replace(@explode_left_re, str, fn _, n, tail ->
      n = String.to_integer(n) + value
      to_string(n) <> tail
    end)
  end

  @explode_right_re ~r/^ ([^\d]+) (\d+)/x

  @doc ~S"""
  iex> Day18.explode_right(",1],2],3],4]", 8)
  ",9],2],3],4]"
  """
  def explode_right(str, value) do
    Regex.replace(@explode_right_re, str, fn _, head, n ->
      n = String.to_integer(n) + value
      head <> to_string(n)
    end)
  end

  @split_re ~r/(\d\d+)/

  @doc ~S"""
  Splits once.

  iex> Day18.split("[[1,[15,9]],15]")
  "[[1,[[7,8],9]],15]"
  """
  def split(pairs) do
    Regex.replace(
      @split_re,
      pairs,
      fn n ->
        n = String.to_integer(n)
        "[#{div(n, 2)},#{round(n / 2)}]"
      end,
      global: false
    )
  end

  @doc ~S"""
  Reduces fully.

  iex> Day18.reduce("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
  "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
  """
  def reduce(pairs) do
    case explode(pairs) do
      ps when ps != pairs ->
        reduce(ps)

      _ ->
        case split(pairs) do
          ps when ps != pairs -> reduce(ps)
          _ -> pairs
        end
    end
  end

  @doc ~S"""
  Sums a list of pairs.

  iex> Day18.sum(~w{ [1,1] [2,2] [3,3] [4,4] [5,5] [6,6] })
  "[[[[5,0],[7,4]],[5,5]],[6,6]]"
  """
  def sum([first | rest]), do: reduce(sum(rest, first))

  defp sum([], acc), do: acc
  defp sum([next | rest], acc), do: sum(rest, reduce("[#{acc},#{next}]"))

  @doc ~S"""
  iex> Day18.magnitude("[[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]")
  3488
  """
  def magnitude(expression) do
    if String.starts_with?(expression, "[") do
      {first, second} = split_pair(expression)
      3 * magnitude(first) + 2 * magnitude(second)
    else
      String.to_integer(expression)
    end
  end

  @doc ~S"""
  iex> {pair, rest} = Day18.next_pair("[1,[3,4]],[[[3,[4,5]],6],[7,8]]]")
  iex> pair
  "[1,[3,4]]"
  iex> rest
  ",[[[3,[4,5]],6],[7,8]]]"
  iex> {pair, rest} = Day18.next_pair(rest)
  iex> pair
  "[[[3,[4,5]],6],[7,8]]"
  iex> rest
  "]"
  """
  def next_pair(expression, depth \\ 0, acc \\ "")

  def next_pair("[" <> rest, depth, acc), do: next_pair(rest, depth + 1, acc <> "[")

  def next_pair("]" <> rest, 1, acc), do: {acc <> "]", rest}

  def next_pair("]" <> rest, depth, acc), do: next_pair(rest, depth - 1, acc <> "]")

  def next_pair(expression, 0, acc) do
    {_first, rest} = String.split_at(expression, 1)
    next_pair(rest, 0, acc)
  end

  def next_pair(expression, depth, acc) do
    {first, rest} = String.split_at(expression, 1)
    next_pair(rest, depth, acc <> first)
  end

  def next_expression(expression) do
    if String.starts_with?(expression, "[") do
      next_pair(expression)
    else
      {num, rest} = Integer.parse(expression)
      {to_string(num), rest}
    end
  end

  @doc ~S"""
  iex> Day18.split_pair("[1,2]")
  {"1", "2"}

  iex> Day18.split_pair("[[1,[3,4]],[[[3,[4,5]],6],[7,8]]]")
  {"[1,[3,4]]", "[[[3,[4,5]],6],[7,8]]"}
  """
  def split_pair("[" <> rest) do
    {exp1, "," <> rest} = next_expression(rest)
    {exp2, _rest} = next_expression(rest)
    {exp1, exp2}
  end

  @doc ~S"""
  iex> Day18.part1("test-input.txt")
  4140
  """
  def part1(filename \\ "input.txt") do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&reduce/1)
    |> sum()
    |> magnitude()
  end

  @doc ~S"""
  iex> Day18.part2("test-input.txt")
  3993
  """
  def part2(filename \\ "input.txt") do
    numbers =
      filename
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(&reduce/1)

    Enum.flat_map(numbers, fn a ->
      Enum.flat_map(numbers, fn b ->
        if a == b, do: [], else: [magnitude(sum([a, b]))]
      end)
    end)
    |> Enum.sort()
    |> List.last()
  end
end
