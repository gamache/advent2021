defmodule Day05 do
  @input "input.txt"
         |> File.read!()
         |> String.trim_trailing()
         |> String.split("\n")

  @type line :: %{x1: integer, y1: integer, x2: integer, y2: integer}

  @spec parse_line(String.t()) :: line
  defp parse_line(str) do
    [pair1, pair2] = String.split(str, " -> ")
    [x1, y1] = String.split(pair1, ",")
    [x2, y2] = String.split(pair2, ",")
    %{x1: to_int(x1), y1: to_int(y1), x2: to_int(x2), y2: to_int(y2)}
  end

  defp to_int(str) do
    {i, ""} = Integer.parse(str)
    i
  end

  defp vertical?(line), do: line.x1 == line.x2

  defp horizontal?(line), do: line.y1 == line.y2

  defp diagonal?(line), do: !vertical?(line) && !horizontal?(line)

  def part1 do
    lines =
      @input
      |> Enum.map(&parse_line/1)
      |> Enum.filter(fn line -> !diagonal?(line) end)

    ## key is {x, y}, value is number of lines crossing that coordinate
    coords =
      Enum.reduce(lines, %{}, fn line, acc ->
        if horizontal?(line) do
          Enum.reduce(line.x1..line.x2, acc, fn x, acc2 ->
            coord = {x, line.y1}
            count = acc2[coord] || 0
            Map.put(acc2, coord, count + 1)
          end)
        else
          # vertical
          Enum.reduce(line.y1..line.y2, acc, fn y, acc2 ->
            coord = {line.x1, y}
            count = acc2[coord] || 0
            Map.put(acc2, coord, count + 1)
          end)
        end
      end)

    coords
    |> Enum.filter(fn {_coord, count} -> count > 1 end)
    |> Enum.count()
  end

  def part2 do
    lines =
      @input
      |> Enum.map(&parse_line/1)

    ## key is {x, y}, value is number of lines crossing that coordinate
    coords =
      Enum.reduce(lines, %{}, fn line, acc ->
        cond do
          horizontal?(line) ->
            Enum.reduce(line.x1..line.x2, acc, fn x, acc2 ->
              coord = {x, line.y1}
              count = acc2[coord] || 0
              Map.put(acc2, coord, count + 1)
            end)

          vertical?(line) ->
            Enum.reduce(line.y1..line.y2, acc, fn y, acc2 ->
              coord = {line.x1, y}
              count = acc2[coord] || 0
              Map.put(acc2, coord, count + 1)
            end)

          :else ->
            # diagonal
            xsign = if line.x1 < line.x2, do: 1, else: -1
            ysign = if line.y1 < line.y2, do: 1, else: -1
            range = abs(line.x1 - line.x2)

            Enum.reduce(0..range, acc, fn i, acc2 ->
              x = line.x1 + xsign * i
              y = line.y1 + ysign * i

              coord = {x, y}
              count = acc2[coord] || 0
              Map.put(acc2, coord, count + 1)
            end)
        end
      end)

    coords
    |> Enum.filter(fn {_coord, count} -> count > 1 end)
    |> Enum.count()
  end
end
