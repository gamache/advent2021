defmodule Day17 do
  @type target :: %{xmin: integer, xmax: integer, ymin: integer, ymax: integer}
  @type state :: %{x: integer, y: integer, vx: integer, vy: integer}

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
    (state.y < target.ymin && state.vy < 0) ||
      state.x > target.xmax ||
      (state.x < target.xmin && state.vx == 0)
  end

  @spec hits_target?(state, target) :: boolean
  defp hits_target?(state, target) do
    cond do
      in_target?(state, target) -> true
      past_target?(state, target) -> false
      :else -> state |> step() |> hits_target?(target)
    end
  end

  ## Returns all starting states that *might* hit the target.
  @spec starting_states(target) :: [state]
  defp starting_states(target) do
    for vx <- 0..target.xmax,
        vy <- target.ymin..abs(target.ymin) do
      %{x: 0, y: 0, vx: vx, vy: vy}
    end
  end

  ## Returns the highest Y achievable while hitting the target.
  @spec find_best_y(target) :: integer
  defp find_best_y(target) do
    target
    |> starting_states()
    |> Enum.filter(fn state -> hits_target?(state, target) end)
    |> Enum.map(&find_max_y/1)
    |> Enum.sort()
    |> List.last()
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
  @spec find_hits(target) :: [state]
  defp find_hits(target) do
    target
    |> starting_states()
    |> Enum.filter(fn state -> hits_target?(state, target) end)
  end

  def part2(filename \\ "input.txt") do
    filename
    |> target
    |> find_hits()
    |> Enum.count()
  end
end
