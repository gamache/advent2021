defmodule Day09 do
  ## {row, col}
  @type coord :: {non_neg_integer, non_neg_integer}

  ## %{ {row, col} => height }
  @type heightmap :: %{coord => non_neg_integer}

  @spec heightmap(String.t()) :: heightmap
  defp heightmap(filename) do
    filename
    |> File.read!()
    |> String.trim()
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {char, col} ->
        {{row, col}, String.to_integer(char)}
      end)
    end)
    |> Enum.into(%{})
  end

  @spec adjacent_coords(coord) :: [coord]
  defp adjacent_coords({row, col}) do
    [
      {row - 1, col},
      {row + 1, col},
      {row, col - 1},
      {row, col + 1},
    ]
  end

  @spec local_minimum?(heightmap, coord, [coord]) :: boolean
  defp local_minimum?(heightmap, coord, except \\ []) do
    height = heightmap[coord]

    coord
    |> adjacent_coords()
    |> Enum.filter(fn c -> !(c in except) end)
    |> Enum.all?(fn adj_coord ->
      adj = heightmap[adj_coord]
      adj == nil || adj > height
    end)
  end

  def part1(filename \\ "input.txt") do
    heightmap = heightmap(filename)

    heightmap
    |> Enum.filter(fn {coord, _height} -> local_minimum?(heightmap, coord) end)
    |> Enum.map(fn {_coord, height} -> height + 1 end)
    |> Enum.sum()
  end

  defp find_basin(heightmap, coord) do
    find_basin(heightmap, adjacent_coords(coord), [coord])
  end

  defp find_basin(_heightmap, [], basin), do: basin

  defp find_basin(heightmap, coords_to_check, basin) do
    #IO.inspect(coords_to_check, label: :to_check)
    #IO.inspect(basin, label: :basin)

    new_coords =
      coords_to_check
      |> Enum.filter(fn coord -> heightmap[coord] end)
      |> Enum.filter(fn coord -> heightmap[coord] < 9 end)
      |> Enum.filter(fn coord -> !(coord in basin) end)
      |> Enum.filter(fn coord -> local_minimum?(heightmap, coord, basin) end)

    next_coords =
      new_coords
      |> Enum.flat_map(&adjacent_coords/1)
      |> Enum.filter(fn coord -> !(coord in basin) end)
      #  |> Enum.filter(fn coord -> !(coord in new_coords) end)

    basin = Enum.uniq(basin ++ new_coords)

    find_basin(heightmap, next_coords, basin)
  end

  def part2(filename \\ "input.txt") do
    heightmap = heightmap(filename)

    minima =
      heightmap
      |> Enum.filter(fn {coord, _height} -> local_minimum?(heightmap, coord) end)
      |> Enum.map(fn {coord, _height} -> coord end)

    basins =
      minima
      |> Enum.map(fn coord -> find_basin(heightmap, coord) end)
      |> Enum.sort_by(fn basin -> 0 - Enum.count(basin) end)

    [a, b, c | _] = basins

    Enum.count(a) * Enum.count(b) * Enum.count(c)
  end
end
