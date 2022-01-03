defmodule Day23 do
  @type coord :: {integer, integer}
  @type burrow :: %{map: %{coord => String.t()}, energy: non_neg_integer}

  @spec burrow(String.t()) :: burrow
  def burrow(filename) do
    map =
      filename
      |> File.read!()
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.flat_map(fn
          {char, x} when char in ["A", "B", "C", "D"] -> [{{x, y}, char}]
          _ -> []
        end)
      end)
      |> Enum.into(%{})

    %{map: map, energy: 0}
  end

  @home_room_x %{"A" => 3, "B" => 5, "C" => 7, "D" => 9}
  @cost %{"A" => 1, "B" => 10, "C" => 100, "D" => 1000}

  def valid_moves(burrow, coord)

  ## A pod in the hallway can only move to its room, and only when the room has no
  ## pods of the wrong type
  def valid_moves(burrow, {x, 1} = coord) do
    char = burrow.map[coord]
    home_room_x = @home_room_x[char]

    top_occupied_y_in_home_room =
      case 2..5 |> Enum.filter(fn yy -> burrow.map[{home_room_x, yy}] end) do
        [] -> 6
        ys -> ys |> Enum.min()
      end

    wrong_pods_in_home_room =
      2..5
      |> Enum.filter(fn yy ->
        burrow_char = burrow.map[{home_room_x, yy}]
        burrow_char && burrow_char != char
      end)
      |> Enum.count()

    clear_path_to_home_room? =
      cond do
        home_room_x < x - 1 ->
          home_room_x..(x - 1) |> Enum.all?(fn x -> !burrow.map[{x, 1}] end)

        home_room_x > x + 1 ->
          (x + 1)..home_room_x |> Enum.all?(fn x -> !burrow.map[{x, 1}] end)

        :else ->
          true
      end

    cond do
      wrong_pods_in_home_room > 0 ->
        ## can't move until home room is clear
        []

      clear_path_to_home_room? ->
        ## Fantastic
        [{home_room_x, top_occupied_y_in_home_room - 1}]

      :else ->
        ## can't get there from here
        []
    end
  end

  ## A pod in a room can only move if it's on top, and if the room is shared by pods
  ## of the wrong type
  def valid_moves(burrow, {x, y} = coord) do
    char = burrow.map[coord]
    home_room_x = @home_room_x[char]

    top_occupied_y_in_room =
      case 2..5 |> Enum.filter(fn yy -> burrow.map[{x, yy}] end) do
        [] -> 6
        ys -> ys |> Enum.min()
      end

    other_pods_in_room =
      2..5
      |> Enum.filter(fn yy ->
        burrow_char = burrow.map[{x, yy}]
        burrow_char && burrow_char != char
      end)
      |> Enum.count()

    cond do
      y != top_occupied_y_in_room ->
        ## not the top pod in the room; no legal moves
        []

      x != home_room_x || other_pods_in_room > 0 ->
        ## at least one pod is in the wrong room; get out of here
        left_x_moves = (x - 1)..1 |> Enum.take_while(fn xx -> !burrow.map[{xx, 1}] end)
        right_x_moves = (x + 1)..11 |> Enum.take_while(fn xx -> !burrow.map[{xx, 1}] end)
        x_moves = (left_x_moves ++ right_x_moves) |> Enum.filter(fn x -> !(x in [3, 5, 7, 9]) end)
        Enum.map(x_moves, fn x -> {x, 1} end)

      :else ->
        ## pod is in the correct room, with no pods of wrong type; do nothing
        []
    end
  end

  def valid_next_states(burrow) do
    Enum.flat_map(burrow.map, fn {{x, y} = coord, char} ->
      Enum.map(valid_moves(burrow, coord), fn {xx, yy} = new_coord ->
        energy = burrow.energy + @cost[char] * (abs(x - xx) + abs(y - yy))
        map = burrow.map |> Map.delete(coord) |> Map.put(new_coord, char)
        %{map: map, energy: energy}
      end)
    end)
  end

  @doc ~S"""
  iex> Day23.burrow("end-state.txt") |> Day23.end_state?
  true

  iex> Day23.burrow("input2.txt") |> Day23.end_state?
  false
  """
  def end_state?(burrow) do
    Enum.all?(1..11, fn x -> !burrow.map[{x, 1}] end) &&
      Enum.all?(2..5, fn y -> burrow.map[{3, y}] == "A" end) &&
      Enum.all?(2..5, fn y -> burrow.map[{5, y}] == "B" end) &&
      Enum.all?(2..5, fn y -> burrow.map[{7, y}] == "C" end) &&
      Enum.all?(2..5, fn y -> burrow.map[{9, y}] == "D" end)
  end

  def dijkstra(burrow) do
    heap =
      Heap.new(fn a, b -> a.energy < b.energy end)
      |> Heap.push(burrow)

    dijkstra(heap, %{})
  end

  def dijkstra(heap, known) do
    {burrow, heap} = Heap.split(heap)

    if end_state?(burrow) do
      burrow
    else
      next_states = valid_next_states(burrow) |> remove_known(known)

      new_known =
        next_states |> Enum.map(fn burrow -> {burrow.map, burrow.energy} end) |> Enum.into(%{})

      known = Map.merge(known, new_known)
      heap = Enum.reduce(next_states, heap, fn burrow, acc -> Heap.push(acc, burrow) end)
      dijkstra(heap, known)
    end
  end

  def remove_known(burrows, known) do
    Enum.filter(burrows, fn burrow ->
      case known[burrow.map] do
        nil -> true
        energy -> energy > burrow.energy
      end
    end)
  end

  def inspect_burrow(burrow) do
    IO.puts("\nenergy: #{burrow.energy}, map:")

    Enum.map(1..5, fn y ->
      Enum.map(1..11, fn x -> burrow.map[{x, y}] || "." end) |> Enum.join("")
    end)
    |> Enum.join("\n")
    |> IO.puts()

    burrow
  end

  def part2(filename \\ "input2.txt") do
    filename
    |> burrow
    |> dijkstra
  end
end
