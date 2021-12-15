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
    |> Enum.flat_map(fn {line, row} ->
      line
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn {c, col} -> {{row, col}, String.to_integer(c)} end)
    end)
    |> Enum.into(%{})
  end

  @spec adjacent(coord) :: [coord]
  defp adjacent({x, y}) do
    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  end

  defp dfs(cavern, end_coord, paths, coord_costs) do
    new_paths =
      Task.async_stream(paths, fn path ->
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
      end, ordered: false)
      |> Enum.reduce([], fn {:ok, lst}, acc -> lst ++ acc end)

    ## Determine minimum cost to go to each known coord
    coord_costs = Enum.reduce(new_paths, coord_costs, fn path, acc ->
      %{coords: [coord | _], cost: cost} = path
      case acc[coord] do
        nil -> Map.put(acc, coord, cost)
        c when c > cost -> Map.put(acc, coord, cost)
        _ -> acc
      end
    end)

    ## Don't go to the same coord at a higher cost
    new_paths =
      Enum.filter(new_paths, fn %{coords: [coord | _], cost: cost} ->
        cost <= coord_costs[coord]
      end)

    complete_paths =
      new_paths
      |> Enum.filter(fn p -> p.complete end)
      |> Enum.sort_by(fn p -> p.cost end)

    cond do
      Enum.count(complete_paths) == Enum.count(new_paths) ->
        complete_paths |> Enum.sort_by(fn p -> p.cost end) |> List.first()

      complete_paths == [] ->
        dfs(cavern, end_coord, new_paths, coord_costs)

      :else ->
        ## Remove any paths of higher cost than the cheapest complete path
        [%{cost: cost} | _] = complete_paths
        new_paths = Enum.filter(new_paths, fn p -> p.cost <= cost end)
        dfs(cavern, end_coord, new_paths, coord_costs)
    end
  end

  def part1(filename \\ "input.txt") do
    cavern = cavern(filename)

    [{xmax, _} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {x, _} -> 0 - x end)
    [{_, ymax} | _] = cavern |> Map.keys() |> Enum.sort_by(fn {_, y} -> 0 - y end)

    dfs(cavern, {xmax, ymax}, [%{coords: [{0, 0}], cost: 0, complete: false}], %{})
    |> Map.get(:cost)
  end
end
