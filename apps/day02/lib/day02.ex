defmodule Day02 do
  @input "input.txt"
         |> File.read!()
         |> String.trim_trailing()
         |> String.split("\n")

  def part1 do
    state = execute(@input, %{position: 0, depth: 0})

    state.position * state.depth
  end

  defp execute([], state), do: state

  defp execute([cmd | rest], state) do
    execute(rest, execute1(cmd, state))
  end

  defp execute1("forward " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | position: state.position + i}
  end

  defp execute1("up " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | depth: state.depth - i}
  end

  defp execute1("down " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | depth: state.depth + i}
  end

  def part2 do
    state = part2_execute(@input, %{position: 0, depth: 0, aim: 0})

    state.position * state.depth
  end

  defp part2_execute([], state), do: state

  defp part2_execute([cmd | rest], state) do
    part2_execute(rest, part2_execute1(cmd, state))
  end

  defp part2_execute1("forward " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | position: state.position + i, depth: state.depth + state.aim * i}
  end

  defp part2_execute1("up " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | aim: state.aim - i}
  end

  defp part2_execute1("down " <> x, state) do
    {i, ""} = Integer.parse(x)
    %{state | aim: state.aim + i}
  end
end
