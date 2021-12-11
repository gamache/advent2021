defmodule Day11 do
  @type coord :: {non_neg_integer, non_neg_integer}
  @type grid :: %{coord => non_neg_integer}
  @type state :: %{grid: grid, flashes: non_neg_integer}

  @spec grid(String.t()) :: grid
  defp grid(filename) do
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

  @spec increment(state) :: state
  defp increment(state) do
    grid = state.grid |> Enum.map(fn {k, v} -> {k, v + 1} end) |> Enum.into(%{})
    %{state | grid: grid}
  end

  @spec adjacents(coord) :: [coord]
  defp adjacents({row, col}) do
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

  @spec flash(state, coord) :: state
  defp flash(state, coord) do
    state =
      Enum.reduce(adjacents(coord), state, fn coord, state ->
        grid =
          if state.grid[coord] do
            Map.put(state.grid, coord, state.grid[coord] + 1)
          else
            state.grid
          end

        %{state | grid: grid}
      end)

    %{state | flashes: state.flashes + 1}
  end

  @spec step(state) :: state
  defp step(state) do
    state
    |> increment()
    |> do_flashes()
  end

  @spec do_flashes(state, [coord]) :: state
  defp do_flashes(state, already_flashed_this_step \\ []) do
    flash_coords =
      state.grid
      |> Enum.filter(fn {_coord, value} -> value > 9 end)
      |> Enum.map(fn {coord, _value} -> coord end)
      |> Enum.filter(fn coord -> !(coord in already_flashed_this_step) end)

    if flash_coords == [] do
      ## Reset all flashed coords for this step
      state =
        Enum.reduce(already_flashed_this_step, state, fn coord, state ->
          %{state | grid: Map.put(state.grid, coord, 0)}
        end)

      state
    else
      ## Perform this round of flashes and recurse
      state =
        Enum.reduce(flash_coords, state, fn coord, state ->
          flash(state, coord)
        end)

      do_flashes(state, flash_coords ++ already_flashed_this_step)
    end
  end

  def part1(filename \\ "input.txt") do
    state = %{grid: grid(filename), flashes: 0}
    state = Enum.reduce(1..100, state, fn _, state -> step(state) end)
    state.flashes
  end

  @spec all_flashed?(state) :: boolean
  defp all_flashed?(state) do
    Enum.all?(state.grid, fn {_coord, value} -> value == 0 end)
  end

  @spec steps_until_all_flashed(state, non_neg_integer) :: non_neg_integer
  defp steps_until_all_flashed(state, steps \\ 0) do
    state = step(state)
    steps = steps + 1

    if all_flashed?(state), do: steps, else: steps_until_all_flashed(state, steps)
  end

  def part2(filename \\ "input.txt") do
    state = %{grid: grid(filename), flashes: 0}
    steps_until_all_flashed(state)
  end
end
