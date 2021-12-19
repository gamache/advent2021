defmodule Day19 do
  @type coord :: {integer, integer, integer}
  @type reports :: %{non_neg_integer => [coord]}

  defp reports(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_scanner/1)
    |> Enum.into(%{})
  end

  defp parse_scanner(str) do
    [first, rest] = String.split(str, "\n", trim: true, parts: 2)

    "--- scanner " <> scan_str = first
    {scanner, _} = Integer.parse(scan_str)

    coords = rest |> String.split("\n", trim: true) |> Enum.map(&parse_coord/1)

    {scanner, coords}
  end

  defp parse_coord(str) do
    [x, y, z] = str |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
    {x, y, z}
  end

  def part1(filename \\ "input.txt") do
    filename
    |> reports
  end

  @orientations [
    [[1,0,0], [0,1,0], [0,0,1]],
    [[0,0,1], [0,1,0], [-1,0,0]],
    [[-1,0,0], [0,1,0], [0,0,-1]],
    [[0,0,-1], [0,1,0], [1,0,0]],

    [[0,-1,0],[1,0,0], [0,0,1]],
    [[0,0,1], [1,0,0], [0,1,0]],
    [[0,1,0], [1,0,0], [0,0,-1]],
    [[0,0,-1], [1,0,0], [0, -1, 0]],

    [[0,1,0], [-1,0,0], [0,0,1]],
    [[0,0,1], [-1,0,0], [0,-1,0]],
    [[0,-1,0], [-1,0,0], [0,0,-1]],
    [[0,0,-1], [-1,0,0], [0,1,0]],

    [[1,0,0], [0,0,-1], [0,1,0]],
    [[0,1,0], [0,0,-1], [-1,0,0]],
    [[-1,0,0], [0,0,-1], [0,-1,0]],
    [[0,-1,0], [0,0,-1], [1,0,0]],

    [[1,0,0], [0,-1,0], [0,0,-1]],
    [[0,0,-1], [0,-1,0], [-1,0,0]],
    [[-1,0,0], [0,-1,0], [0,0,1]],
    [[0,0,1], [0,-1,0], [1,0,0]],

    [[1,0,0], [0,0,1], [0,-1,0]],
    [[0,-1,0], [0,0,1], [-1,0,0]],
    [[-1,0,0], [0,0,1], [0,1,0]],
    [[0,1,0], [0,0,1], [1,0,0]]
  ]
  |> Enum.map(&Matrex.new/1)

  def rotate(coord) do
    Enum.map(@orientations, fn orient ->
      coord |> Matrex.new() |> Matrex.transpose() |> Matrex.multiply(orient)
    end)
  end
end
