defmodule Day15 do
  @type coord :: {non_neg_integer, non_neg_integer}
  @type cavern :: %{coord => non_neg_integer}
  @type path :: %{coords: [coord], cost: non_neg_integer, complete: boolean}

  @spec cavern(String.t()) :: cavern
  defp cavern(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} -> {{x, y}, String.to_integer(c)} end)
    end)
    |> Enum.into(%{})
  end

  @spec adjacent(coord) :: [coord]
  defp adjacent({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp bfs(cavern, end_coord, paths, coord_costs) do
    :erlang.system_time(:second) |> IO.inspect(label: :entered_bfs_at)
    coord_costs |> map_size() |> IO.inspect(label: :costs_count)
    paths |> Enum.count() |> IO.inspect(label: :paths_count)

    new_paths =
      Enum.flat_map(paths, fn path ->
        if path.complete do
          [path]
        else
          [coord | _] = path.coords

          Enum.flat_map(adjacent(coord), fn adj_coord ->
            cond do
              !cavern[adj_coord] ->
                ## Coordinate must exist
                []

              adj_coord in path.coords ->
                ## No cycles allowed
                []

              :else ->
                [
                  %{
                    coords: [adj_coord | path.coords],
                    cost: path.cost + cavern[adj_coord],
                    complete: adj_coord == end_coord
                  }
                ]
            end
          end)
        end
      end)

    ## Determine minimum cost path to go to each known coord
    coord_costs =
      Enum.reduce(new_paths, coord_costs, fn path, acc ->
        %{coords: [coord | _], cost: cost} = path

        case acc[coord] do
          nil -> Map.put(acc, coord, path)
          %{cost: c} when c > cost -> Map.put(acc, coord, path)
          _ -> acc
        end
      end)

    ## Don't go to the same coord at a higher cost.
    ## Additionally, trim equal costs to a single path.
    new_paths =
      Enum.filter(new_paths, fn %{coords: [coord | _]} = path ->
        cheapest_path = coord_costs[coord]
        path.cost < cheapest_path.cost || path == cheapest_path
      end)

    complete_paths =
      new_paths
      |> Enum.filter(fn p -> p.complete end)
      |> Enum.sort_by(fn p -> p.cost end)

    cond do
      Enum.count(complete_paths) == Enum.count(new_paths) ->
        complete_paths |> Enum.sort_by(fn p -> p.cost end) |> List.first()

      complete_paths == [] ->
        bfs(cavern, end_coord, new_paths, coord_costs)

      :else ->
        ## Remove any paths of higher cost than the cheapest complete path
        [%{cost: cost} | _] = complete_paths
        new_paths = Enum.filter(new_paths, fn p -> p.cost <= cost end)
        bfs(cavern, end_coord, new_paths, coord_costs)
    end
  end

  def part1(filename \\ "input.txt") do
    cavern = cavern(filename)

    [{xmax, _} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {_, y} -> 0 - y end)

    bfs(cavern, {xmax, ymax}, [%{coords: [{0, 0}], cost: 0, complete: false}], %{})
    |> Map.get(:cost)
  end

  defp inc(x, n) do
    cond do
      n + x > 9 -> n + x - 9
      :else -> n + x
    end
  end

  defp big_cavern(filename) do
    cavern = cavern(filename)
    [{xmax, _} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {_, y} -> 0 - y end)

    cavern
    |> Enum.reduce(%{}, fn {{x, y}, cost}, acc ->
      Map.merge(acc, %{
        {x, y} => cost,
        {x + (xmax + 1), y} => inc(cost, 1),
        {x + (xmax + 1) * 2, y} => inc(cost, 2),
        {x + (xmax + 1) * 3, y} => inc(cost, 3),
        {x + (xmax + 1) * 4, y} => inc(cost, 4)
      })
    end)
    |> Enum.reduce(%{}, fn {{x, y}, cost}, acc ->
      Map.merge(acc, %{
        {x, y} => cost,
        {x, y + (ymax + 1)} => inc(cost, 1),
        {x, y + (ymax + 1) * 2} => inc(cost, 2),
        {x, y + (ymax + 1) * 3} => inc(cost, 3),
        {x, y + (ymax + 1) * 4} => inc(cost, 4)
      })
    end)
  end

  def part2(filename \\ "input.txt") do
    cavern = big_cavern(filename)

    [{xmax, _} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {_, y} -> 0 - y end)

    bfs(cavern, {xmax, ymax}, [%{coords: [{0, 0}], cost: 0, complete: false}], %{})
    |> Map.get(:cost)
  end

  defp grid_to_string(grid) do
    keys = Map.keys(grid)
    [{xmin, _} | _] = Enum.sort_by(keys, fn {x, _} -> x end)
    [{_, ymin} | _] = Enum.sort_by(keys, fn {_, y} -> y end)
    [{xmax, _} | _] = Enum.sort_by(keys, fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = Enum.sort_by(keys, fn {_, y} -> 0 - y end)

    ymin..ymax
    |> Enum.map(fn y ->
      xmin..xmax
      |> Enum.map(fn x -> grid[{x, y}] end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end
