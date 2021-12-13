defmodule Day13 do
  @type coord :: {non_neg_integer, non_neg_integer}
  @type grid :: %{coord => boolean}
  @type fold :: {:x, non_neg_integer} | {:y, non_neg_integer}
  @type input :: {grid, [fold]}

  @spec input(String.t()) :: input
  defp input(filename) do
    [coords, folds] =
      filename
      |> File.read!()
      |> String.split("\n\n", trim: true)

    grid =
      coords
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_coord/1)
      |> Enum.map(fn coord -> {coord, true} end)
      |> Enum.into(%{})

    folds =
      folds
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_fold/1)

    {grid, folds}
  end

  @spec parse_coord(String.t()) :: coord
  defp parse_coord(str) do
    [x, y] = String.split(str, ",")
    {String.to_integer(x), String.to_integer(y)}
  end

  @spec parse_fold(String.t()) :: fold
  defp parse_fold("fold along x=" <> x), do: {:x, String.to_integer(x)}
  defp parse_fold("fold along y=" <> y), do: {:y, String.to_integer(y)}

  @spec fold(fold, grid) :: grid
  defp fold({:x, fold_x}, grid) do
    Enum.reduce(grid, %{}, fn {{old_x, y}, _}, acc ->
      new_x =
        if old_x > fold_x do
          fold_x - abs(old_x - fold_x)
        else
          old_x
        end

      Map.put(acc, {new_x, y}, true)
    end)
  end

  defp fold({:y, fold_y}, grid) do
    Enum.reduce(grid, %{}, fn {{x, old_y}, _}, acc ->
      new_y =
        if old_y > fold_y do
          fold_y - abs(old_y - fold_y)
        else
          old_y
        end

      Map.put(acc, {x, new_y}, true)
    end)
  end

  def part1(filename \\ "input.txt") do
    {grid, [fold | _rest]} = input(filename)

    fold(fold, grid)
    |> Enum.count()
  end

  @spec grid_to_string(grid) :: String.t()
  defp grid_to_string(grid) do
    keys = Map.keys(grid)
    [{xmin, _} | _] = Enum.sort_by(keys, fn {x, _} -> x end)
    [{_, ymin} | _] = Enum.sort_by(keys, fn {_, y} -> y end)
    [{xmax, _} | _] = Enum.sort_by(keys, fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = Enum.sort_by(keys, fn {_, y} -> 0 - y end)

    ymin..ymax
    |> Enum.map(fn y ->
      xmin..xmax
      |> Enum.map(fn x -> if grid[{x, y}], do: "#", else: " " end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end

  def part2(filename \\ "input.txt") do
    {grid, folds} = input(filename)

    folds
    |> Enum.reduce(grid, &fold/2)
    |> grid_to_string()
    |> IO.puts()
  end
end
