defmodule Day19 do
  ## Scanners are identified by number
  @type scanner :: non_neg_integer

  ## Coordinates are 3D
  @type coord :: [integer]

  ## A report is a coordinate at which a (disoriented) scanner found a beacon
  @type report :: coord

  ## An orientation is a 3x3 matrix describing a unit rotation
  @type orientation :: [coord]

  @type input :: %{scanner => %{orientation => [report]}}

  @identity [[1, 0, 0], [0, 1, 0], [0, 0, 1]]

  @orientations [
    [[1, 0, 0], [0, 1, 0], [0, 0, 1]],
    [[0, 0, 1], [0, 1, 0], [-1, 0, 0]],
    [[-1, 0, 0], [0, 1, 0], [0, 0, -1]],
    [[0, 0, -1], [0, 1, 0], [1, 0, 0]],
    [[0, -1, 0], [1, 0, 0], [0, 0, 1]],
    [[0, 0, 1], [1, 0, 0], [0, 1, 0]],
    [[0, 1, 0], [1, 0, 0], [0, 0, -1]],
    [[0, 0, -1], [1, 0, 0], [0, -1, 0]],
    [[0, 1, 0], [-1, 0, 0], [0, 0, 1]],
    [[0, 0, 1], [-1, 0, 0], [0, -1, 0]],
    [[0, -1, 0], [-1, 0, 0], [0, 0, -1]],
    [[0, 0, -1], [-1, 0, 0], [0, 1, 0]],
    [[1, 0, 0], [0, 0, -1], [0, 1, 0]],
    [[0, 1, 0], [0, 0, -1], [-1, 0, 0]],
    [[-1, 0, 0], [0, 0, -1], [0, -1, 0]],
    [[0, -1, 0], [0, 0, -1], [1, 0, 0]],
    [[1, 0, 0], [0, -1, 0], [0, 0, -1]],
    [[0, 0, -1], [0, -1, 0], [-1, 0, 0]],
    [[-1, 0, 0], [0, -1, 0], [0, 0, 1]],
    [[0, 0, 1], [0, -1, 0], [1, 0, 0]],
    [[1, 0, 0], [0, 0, 1], [0, -1, 0]],
    [[0, -1, 0], [0, 0, 1], [-1, 0, 0]],
    [[-1, 0, 0], [0, 0, 1], [0, 1, 0]],
    [[0, 1, 0], [0, 0, 1], [1, 0, 0]]
  ]

  ## Returns all 24 orientations of a set of beacon coordinates.
  @spec orientations([report]) :: %{orientation => [report]}
  def orientations(coords) do
    @orientations
    |> Enum.map(fn orientation ->
      {orientation,
       Enum.map(coords, fn coord ->
         [[x], [y], [z]] = Matrix.mult(orientation, Matrix.transpose([coord]))
         [x, y, z]
       end)}
    end)
    |> Enum.into(%{})
  end

  ## Returns all orientations of all reports for all scanners.
  @spec input(String.t()) :: input
  def input(filename) do
    filename
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_scanner/1)
    |> Enum.map(fn {k, v} -> {k, orientations(v)} end)
    |> Enum.into(%{})
  end

  @spec parse_scanner(String.t()) :: scanner
  defp parse_scanner(str) do
    [first, rest] = String.split(str, "\n", trim: true, parts: 2)
    "--- scanner " <> scan_str = first
    {scanner, _} = Integer.parse(scan_str)
    reports = rest |> String.split("\n", trim: true) |> Enum.map(&parse_report/1)
    {scanner, reports}
  end

  @spec parse_report(String.t()) :: report
  defp parse_report(str) do
    str |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
  end

  ## If 12 or more beacons match, returns the diff between a and b.
  ## Diff is in coordinates relative to a.
  @spec compare_beacons([coord], [coord]) :: nil | coord
  def compare_beacons(a_beacons, b_beacons) do
    beacon_diffs =
      Enum.flat_map(a_beacons, fn [ax, ay, az] = a ->
        Enum.map(b_beacons, fn [bx, by, bz] ->
          diff = [ax - bx, ay - by, az - bz]
          {diff, a}
        end)
      end)

    ## Look for 12 or more instances of the same diff (offset from a to b)
    beacon_diffs
    |> Enum.map(fn {k, _v} -> k end)
    |> Enum.frequencies()
    |> Enum.filter(fn {_, v} -> v >= 12 end)
    |> Enum.map(fn {k, _} -> k end)
    |> List.first()
  end

  ## Compares a (in its known orientation) to all orientations of b. When 12 or more
  ## beacons are matched, returns the orientation of b, the absolute coords of b, and
  ## absolute coordinates of the beacons matched between a and b.
  @spec compare_a_to_bs(input, %{scanner => {orientation, coord}}, scanner, scanner, [
          orientation
        ]) ::
          nil | {orientation, coord}
  defp compare_a_to_bs(input, known_scanners, a, b, b_orientations \\ @orientations)

  defp compare_a_to_bs(_input, _known_scanners, _a, _b, []), do: nil

  defp compare_a_to_bs(input, known_scanners, a, b, [b_orientation | rest]) do
    {a_orientation, [ax, ay, az]} = known_scanners[a]

    case compare_beacons(input[a][a_orientation], input[b][b_orientation]) do
      nil ->
        compare_a_to_bs(input, known_scanners, a, b, rest)

      [bx, by, bz] ->
        ## move diff into absolute coordinates
        diff = [ax + bx, ay + by, az + bz]
        {b_orientation, diff}
    end
  end

  ## Returns a map containing {orientation, coord} for all scanners.
  defp map_scanners(input) do
    map_scanners(input, [0], %{0 => {@identity, [0, 0, 0]}})
  end

  defp map_scanners(input, as, scanner_map) do
    if map_size(scanner_map) == map_size(input) do
      scanner_map
    else
      new_scanner_map =
        Enum.reduce(as, scanner_map, fn a, acc ->
          Enum.reduce(Map.keys(input), acc, fn b, acc2 ->
            if acc2[b] do
              ## b is already known
              acc2
            else
              case compare_a_to_bs(input, acc2, a, b) do
                nil ->
                  acc2

                {b_orientation, b_coord} ->
                  Map.put(acc2, b, {b_orientation, b_coord})
              end
            end
          end)
        end)

      new_scanners = Map.keys(new_scanner_map) -- Map.keys(scanner_map)

      map_scanners(input, new_scanners, new_scanner_map)
    end
  end

  defp beacons(input, scanner_map \\ nil) do
    scanner_map = scanner_map || map_scanners(input)

    input
    |> Map.keys()
    |> Enum.flat_map(fn scanner ->
      {orientation, [dx, dy, dz]} = scanner_map[scanner]

      input[scanner][orientation]
      |> Enum.map(fn [x, y, z] -> [x + dx, y + dy, z + dz] end)
    end)
    |> Enum.uniq()
  end

  def part1(filename \\ "input.txt") do
    filename
    |> input()
    |> beacons()
    |> Enum.count()
  end

  def part2(filename \\ "input.txt") do
    scanner_map = filename |> input() |> map_scanners()

    distances =
      Enum.flat_map(Map.keys(scanner_map), fn a ->
        Enum.map(Map.keys(scanner_map), fn b ->
          {_orient, [ax, ay, az]} = scanner_map[a]
          {_orient, [bx, by, bz]} = scanner_map[b]
          abs(ax - bx) + abs(ay - by) + abs(az - bz)
        end)
      end)

    distances |> Enum.sort() |> List.last()
  end
end
