defmodule Day25 do
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, c} end)
    end)
    |> Enum.into(%{})
  end

  def move_down(input) do
    xmax = input |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    ymax = input |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    Enum.reduce(0..xmax, input, fn x, acc ->
      Enum.reduce(0..ymax, acc, fn y, acc2 ->
        case input[{x, y}] do
          "v" ->
            case input[{x, rem(y + 1, ymax + 1)}] do
              "." ->
                Map.merge(acc2, %{
                  {x, y} => ".",
                  {x, rem(y + 1, ymax + 1)} => "v"
                })

              _ ->
                acc2
            end

          _ ->
            acc2
        end
      end)
    end)
  end

  def move_right(input) do
    xmax = input |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.max()
    ymax = input |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.max()

    Enum.reduce(0..xmax, input, fn x, acc ->
      Enum.reduce(0..ymax, acc, fn y, acc2 ->
        case input[{x, y}] do
          ">" ->
            case input[{rem(x + 1, xmax + 1), y}] do
              "." ->
                Map.merge(acc2, %{
                  {x, y} => ".",
                  {rem(x + 1, xmax + 1), y} => ">"
                })

              _ ->
                acc2
            end

          _ ->
            acc2
        end
      end)
    end)
  end

  def step(input) do
    input
    |> move_right
    |> move_down
  end

  def move_until_stop(input, turns \\ 1) do
    case step(input) do
      ^input -> turns
      other -> move_until_stop(other, turns + 1)
    end
  end

  def part1(filename \\ "input.txt") do
    filename |> input |> move_until_stop
  end
end
