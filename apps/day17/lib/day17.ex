defmodule Day17 do
  @type target :: %{xmin: integer, xmax: integer, ymin: integer, ymax: integer}
  @type state :: %{x: integer, y: integer, vx: integer, vy: integer}
  @type coord :: {integer, integer}

  defp target(filename) do
    "target area: " <> targets = filename |> File.read!() |> String.trim()
    ["x=" <> xs, "y=" <> ys] = String.split(targets, ", ")
    [xmin, xmax] = String.split(xs, "..")
    [ymin, ymax] = String.split(ys, "..")

    %{
      xmin: String.to_integer(xmin),
      xmax: String.to_integer(xmax),
      ymin: String.to_integer(ymin),
      ymax: String.to_integer(ymax)
    }
  end

  defp step(state) do
    x = state.x + state.vx
    y = state.y + state.vy

    vx =
      cond do
        state.vx > 0 -> state.vx - 1
        state.vx < 0 -> state.vx + 1
        :else -> state.vx
      end

    vy = state.vy - 1

    %{x: x, y: y, vx: vx, vy: vy}
  end

  @spec in_target?(state, target) :: boolean
  defp in_target?(state, target) do
    state.x >= target.xmin &&
      state.x <= target.xmax &&
      state.y >= target.ymin &&
      state.y <= target.ymax
  end

  @spec past_target?(state, target) :: boolean
  defp past_target?(state, target) do
    state.y < target.ymin && state.vy < 0
  end

  @spec hits_target?(state, target) :: boolean
  defp hits_target?(state, target) do
    cond do
      in_target?(state, target) -> true
      past_target?(state, target) -> false
      :else -> state |> step() |> hits_target?(target)
    end
  end

  ## Returns lists of coords exactly `d` moves from 0,0.
  @spec first_quadrant_coords(non_neg_integer) :: [coord]
  defp first_quadrant_coords(d) do
    (Enum.map(0..d, fn x -> {x, d} end) ++ Enum.map(0..d, fn y -> {d, y} end))
    |> Enum.uniq()
  end

  @spec fourth_quadrant_coords(non_neg_integer) :: [coord]
  defp fourth_quadrant_coords(d) do
    (Enum.map(0..d, fn x -> {x, 0 - d} end) ++ Enum.map(0..d, fn y -> {d, 0 - y} end))
    |> Enum.uniq()
  end

  ## Returns maximum extent of X,Y velocities to check.
  defp dmax(target) do
    max(abs(target.ymin), target.xmax)
  end

  ## Returns the highest Y achievable while hitting the target.
  @spec find_best_y(target, non_neg_integer, non_neg_integer, non_neg_integer) :: non_neg_integer
  defp find_best_y(target, dmax \\ nil, d \\ 1, best_y \\ 0) do
    dmax = if dmax, do: dmax, else: dmax(target)

    states =
      d
      |> first_quadrant_coords()
      |> Enum.map(fn {vx, vy} -> %{x: 0, y: 0, vx: vx, vy: vy} end)

    hits = Enum.filter(states, fn state -> hits_target?(state, target) end)

    cond do
      d > dmax ->
        best_y

      Enum.count(hits) > 0 ->
        ## maybe hit a new best
        y = hits |> Enum.map(&find_max_y/1) |> Enum.max()
        best_y = if y > best_y, do: y, else: best_y
        find_best_y(target, dmax, d + 1, best_y)

      :else ->
        ## we haven't hit anything yet, keep going
        find_best_y(target, dmax, d + 1, best_y)
    end
  end

  ## Returns the highest Y achieved by this state.
  @spec find_max_y(state, non_neg_integer) :: non_neg_integer
  defp find_max_y(state, max_y \\ 0) do
    if state.y >= max_y do
      state |> step() |> find_max_y(state.y)
    else
      max_y
    end
  end

  def part1(filename \\ "input.txt") do
    filename
    |> target()
    |> find_best_y()
  end

  ## Returns all starting states that hit the target.
  @spec find_all_velocities(target, non_neg_integer) :: [state]
  defp find_all_velocities(target, dmax \\ nil) do
    dmax = if dmax, do: dmax, else: dmax(target)

    coords =
      Enum.flat_map(1..dmax, &first_quadrant_coords/1) ++
        Enum.flat_map(1..dmax, &fourth_quadrant_coords/1)

    coords
    |> Enum.uniq()
    |> Enum.map(fn {vx, vy} -> %{x: 0, y: 0, vx: vx, vy: vy} end)
    |> Enum.filter(fn state -> hits_target?(state, target) end)
  end

  def part2(filename \\ "input.txt") do
    filename
    |> target
    |> find_all_velocities()
    |> Enum.count()
  end
end
