defmodule Day12 do
  @type cave :: String.t()
  @type edges :: %{cave => [cave]}
  @type path :: [cave]

  @spec edges(String.t()) :: edges
  defp edges(filename) do
    pairs =
      filename
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.split(line, "-") end)

    Enum.reduce(pairs, %{}, fn [x, y], acc ->
      xs = Map.get(acc, x, [])
      ys = Map.get(acc, y, [])

      Map.merge(acc, %{x => [y | xs], y => [x | ys]})
    end)
  end

  @spec paths(edges) :: [path]
  defp paths(edges) do
    bfs(edges, "start", ["start"])
  end

  @spec small?(cave) :: boolean
  defp small?(cave), do: cave == String.downcase(cave)

  @spec bfs(edges, cave, path) :: [path]
  defp bfs(edges, from, path) do
    Enum.flat_map(edges[from], fn to ->
      cond do
        to == "end" -> [Enum.reverse(["end" | path])]
        to == "start" -> []
        small?(to) && to in path -> []
        :else -> bfs(edges, to, [to | path])
      end
    end)
  end

  def part1(filename \\ "input.txt") do
    edges = edges(filename)
    paths = paths(edges)
    Enum.count(paths)
  end

  @spec paths_part2(edges) :: [path]
  defp paths_part2(edges) do
    bfs_part2(edges, "start", ["start"], nil)
  end

  @spec bfs_part2(edges, cave, path, cave | nil) :: [path]
  defp bfs_part2(edges, from, path, doubled) do
    Enum.flat_map(edges[from], fn to ->
      cond do
        to == "end" -> [Enum.reverse(["end" | path])]
        to == "start" -> []
        small?(to) && to in path && !doubled -> bfs_part2(edges, to, [to | path], to)
        small?(to) && to in path -> []
        :else -> bfs_part2(edges, to, [to | path], doubled)
      end
    end)
  end

  def part2(filename \\ "input.txt") do
    edges = edges(filename)
    paths = paths_part2(edges)
    Enum.count(paths)
  end
end
