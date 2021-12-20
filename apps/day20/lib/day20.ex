defmodule Day20 do
  @type coord :: {integer, integer}
  @type algo :: %{non_neg_integer => boolean}
  @type pixels :: %{coord => boolean}
  @type image :: %{algo: algo, pixels: pixels, default: boolean}

  @spec image(String.t()) :: image
  def image(filename) do
    [algo, image] = filename |> File.read!() |> String.split("\n\n", split: true)

    algo =
      algo
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.map(fn
        {"#", index} -> {index, true}
        {".", index} -> {index, false}
      end)
      |> Enum.into(%{})

    pixels =
      image
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {"#", x} -> [{{x, y}, true}]
          {".", x} -> [{{x, y}, false}]
        end)
      end)
      |> Enum.into(%{})

    %{algo: algo, pixels: pixels, default: false}
  end

  ## Returns {{xmin, ymin}, {xmax, ymax}}
  @spec bounds(image) :: {coord, coord}
  def bounds(image) do
    {xmin, xmax} = image.pixels |> Enum.map(fn {{x, _y}, _val} -> x end) |> Enum.min_max()
    {ymin, ymax} = image.pixels |> Enum.map(fn {{_x, y}, _val} -> y end) |> Enum.min_max()
    {{xmin, ymin}, {xmax, ymax}}
  end

  ## Returns next pixel value for the given coord.
  @spec next_pixel(image, coord) :: boolean
  def next_pixel(image, {x, y}) do
    coords =
      Enum.flat_map((y - 1)..(y + 1), fn yy ->
        Enum.map((x - 1)..(x + 1), fn xx ->
          {xx, yy}
        end)
      end)

    algo_index =
      coords
      |> Enum.map(fn coord ->
        if Map.get(image.pixels, coord, image.default), do: "1", else: "0"
      end)
      |> Enum.join("")
      |> String.to_integer(2)

    image.algo[algo_index]
  end

  @spec enhance(image) :: image
  def enhance(image) do
    {{xmin, ymin}, {xmax, ymax}} = bounds(image)

    pixels =
      Enum.flat_map((ymin - 1)..(ymax + 1), fn y ->
        Enum.map((xmin - 1)..(xmax + 1), fn x ->
          coord = {x, y}
          {coord, next_pixel(image, coord)}
        end)
      end)
      |> Enum.into(%{})

    default =
      case image.algo[0] do
        true -> !image.default
        false -> image.default
      end

    %{image | pixels: pixels, default: default}
  end

  @spec count_lit_pixels(image) :: non_neg_integer
  def count_lit_pixels(image) do
    image.pixels
    |> Enum.filter(fn {_coord, val} -> val end)
    |> Enum.count()
  end

  def part1(filename \\ "input.txt") do
    filename
    |> image()
    |> enhance()
    |> enhance()
    |> count_lit_pixels()
  end

  def part2(filename \\ "input.txt") do
    image = image(filename)

    Enum.reduce(1..50, image, fn _, acc -> enhance(acc) end)
    |> count_lit_pixels()
  end
end
