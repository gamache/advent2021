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
      {row - 1, col - 1},
      {row - 1, col},
      {row - 1, col + 1},
      {row, col - 1},
      {row, col + 1},
      {row + 1, col - 1},
      {row + 1, col},
      {row + 1, col + 1}
    ]
  end

  @spec local_minimum?(heightmap, coord) :: boolean
  defp local_minimum?(heightmap, coord) do
    height = heightmap[coord]

    Enum.all?(adjacent_coords(coord), fn adj_coord ->
      adj = heightmap[adj_coord]
      adj == nil || adj >= height
    end)
  end

  def part1(filename \\ "input.txt") do
    heightmap = heightmap(filename)

    heightmap
    |> Enum.filter(fn {coord, _height} -> local_minimum?(heightmap, coord) end)
    |> Enum.map(fn {_coord, height} -> height + 1 end)
    |> Enum.sum()
  end
end
