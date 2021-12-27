defmodule Day22 do
  @type region :: %{
          on: boolean,
          xmin: integer,
          xmax: integer,
          ymin: integer,
          ymax: integer,
          zmin: integer,
          zmax: integer
        }

  @spec regions(String.t()) :: [region]
  def regions(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_region/1)
  end

  @spec parse_region(String.t()) :: region
  def parse_region(str) do
    [onoff, rest] = String.split(str, " ")
    on = onoff == "on"

    ["x=" <> xrest, "y=" <> yrest, "z=" <> zrest] = String.split(rest, ",")

    [xmin, xmax] = xrest |> String.split("..") |> Enum.map(&String.to_integer/1)
    [ymin, ymax] = yrest |> String.split("..") |> Enum.map(&String.to_integer/1)
    [zmin, zmax] = zrest |> String.split("..") |> Enum.map(&String.to_integer/1)

    %{on: on, xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax, zmin: zmin, zmax: zmax}
  end

  def lit?(x, y, z, regions, state \\ false)

  def lit?(_, _, _, [], state), do: state

  def lit?(x, y, z, [region | rest], state) do
    if x >= region.xmin && x <= region.xmax && y >= region.ymin && y <= region.ymax &&
         z >= region.zmin && z <= region.zmax do
      lit?(x, y, z, rest, region.on)
    else
      lit?(x, y, z, rest, state)
    end
  end

  def part1(filename \\ "input.txt") do
    regions = regions(filename)

    Enum.reduce(-50..50, 0, fn x, accx ->
      Enum.reduce(-50..50, accx, fn y, accy ->
        Enum.reduce(-50..50, accy, fn z, accz ->
          accz + if lit?(x, y, z, regions), do: 1, else: 0
        end)
      end)
    end)
  end

  ## Strategy:
  ##
  ## Only keep track of "on" regions.
  ##
  ## Every time there is an "off" region, determine the overlap with every
  ## "on" region, and if there is one, decompose the rest of the "on" region
  ## into up to 6 regions: big square-oid regions outside the X bounds,
  ## bar-oid regions outside the Y bounds, and cuboid regions outside the Y
  ## bounds.

  @spec minus_overlap(region, region) :: [region]
  defp minus_overlap(on_region, off_region) do
    case overlap(on_region, off_region) do
      nil ->
        [on_region]

      overlap_region ->
        surrounding_x(on_region, overlap_region) ++
          surrounding_y(on_region, overlap_region) ++
          surrounding_z(on_region, overlap_region)
    end
  end

  defp overlap(a, b) do
    if a.xmax < b.xmin || a.xmin > b.xmax ||
         (a.ymax < b.ymin || a.ymin > b.ymax) ||
         (a.zmax < b.zmin || a.zmin > b.zmax) do
      nil
    else
      %{
        on: b.on,
        xmin: max(a.xmin, b.xmin),
        xmax: min(a.xmax, b.xmax),
        ymin: max(a.ymin, b.ymin),
        ymax: min(a.ymax, b.ymax),
        zmin: max(a.zmin, b.zmin),
        zmax: min(a.zmax, b.zmax)
      }
    end
  end

  defp surrounding_x(on_region, overlap_region) do
    low_x(on_region, overlap_region) ++ high_x(on_region, overlap_region)
  end

  defp surrounding_y(on_region, overlap_region) do
    low_y(on_region, overlap_region) ++ high_y(on_region, overlap_region)
  end

  defp surrounding_z(on_region, overlap_region) do
    low_z(on_region, overlap_region) ++ high_z(on_region, overlap_region)
  end

  defp low_x(on, off) do
    if off.xmin <= on.xmin, do: [], else: [%{on | xmax: off.xmin - 1}]
  end

  defp high_x(on, off) do
    if off.xmax >= on.xmax, do: [], else: [%{on | xmin: off.xmax + 1}]
  end

  defp low_y(on, off) do
    xmin = max(on.xmin, off.xmin)
    xmax = min(on.xmax, off.xmax)
    new = %{on | xmin: xmin, xmax: xmax}

    if off.ymin < on.ymin, do: [], else: [%{new | ymax: off.ymin - 1}]
  end

  defp high_y(on, off) do
    xmin = max(on.xmin, off.xmin)
    xmax = min(on.xmax, off.xmax)
    new = %{on | xmin: xmin, xmax: xmax}

    if off.ymax > on.ymax, do: [], else: [%{new | ymin: off.ymax + 1}]
  end

  defp low_z(on, off) do
    xmin = max(on.xmin, off.xmin)
    xmax = min(on.xmax, off.xmax)
    ymin = max(on.ymin, off.ymin)
    ymax = min(on.ymax, off.ymax)
    new = %{on | xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax}

    if off.zmin < on.zmin, do: [], else: [%{new | zmax: off.zmin - 1}]
  end

  defp high_z(on, off) do
    xmin = max(on.xmin, off.xmin)
    xmax = min(on.xmax, off.xmax)
    ymin = max(on.ymin, off.ymin)
    ymax = min(on.ymax, off.ymax)
    new = %{on | xmin: xmin, xmax: xmax, ymin: ymin, ymax: ymax}

    if off.zmax > on.zmax, do: [], else: [%{new | zmin: off.zmax + 1}]
  end

  def on_regions(regions, acc \\ [])

  def on_regions([], acc), do: acc

  def on_regions([%{on: true} = region | rest], acc) do
    acc = Enum.flat_map(acc, fn acc_region -> minus_overlap(acc_region, region) end)
    on_regions(rest, [region | acc])
  end

  def on_regions([%{on: false} = region | rest], acc) do
    acc = Enum.flat_map(acc, fn acc_region -> minus_overlap(acc_region, region) end)
    on_regions(rest, acc)
  end

  def count(%{on: true} = region) do
    (region.xmax - region.xmin + 1) * (region.ymax - region.ymin + 1) *
      (region.zmax - region.zmin + 1)
  end

  def part2(filename \\ "input.txt") do
    filename |> regions() |> on_regions |> Enum.map(&count/1) |> Enum.sum()
  end
end
