defmodule Day21 do
  @type player :: %{number: non_neg_integer, position: non_neg_integer, score: non_neg_integer}
  @type die :: %{rolls: non_neg_integer, value: non_neg_integer, universes: non_neg_integer}

  @spec players(String.t()) :: [player]
  def players(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_player/1)
  end

  @spec parse_player(String.t()) :: player
  defp parse_player("Player " <> str) do
    [number, position] =
      str
      |> String.split(" starting position: ")
      |> Enum.map(&String.to_integer/1)

    %{number: number, position: position, score: 0, universes: 1}
  end

  def new_die, do: %{rolls: 0, value: 0}

  @doc ~S"""
  iex> Day21.roll(Day21.new_die())
  %{rolls: 1, value: 1}
  iex> Day21.roll(%{rolls: 1, value: 1})
  %{rolls: 2, value: 2}
  iex> Day21.roll(%{rolls: 100, value: 100})
  %{rolls: 101, value: 1}
  """
  @spec roll(die) :: die
  def roll(die) do
    value = 1 + rem(die.rolls, 100)
    %{rolls: die.rolls + 1, value: value}
  end

  ## Returns {turns, loser}
  @spec play([player], die) :: {non_neg_integer, player}
  def play([a, b], die) do
    {a, die} = move(a, die)

    case a do
      %{score: s} when s >= 1000 -> {die.rolls, b}
      _ -> play([b, a], die)
    end
  end

  @spec move(player, die) :: {player, die}
  def move(player, die) do
    position = player.position - 1

    die = roll(die)
    position = position + die.value

    die = roll(die)
    position = position + die.value

    die = roll(die)
    position = position + die.value

    position = 1 + rem(position, 10)

    {%{player | score: player.score + position, position: position}, die}
  end

  def part1(filename \\ "input.txt") do
    {rolls, loser} =
      filename
      |> players
      |> play(new_die())

    rolls * loser.score
  end

  ## @next_position[current_position][nextpos] is the number of universes in which
  ## nextpos is our next position (and the increment to our score)
  @next_position Enum.map(1..10, fn pos ->
                   freqs =
                     for a <- 1..3, b <- 1..3, c <- 1..3 do
                       1 + rem(pos - 1 + a + b + c, 10)
                     end
                     |> Enum.frequencies()

                   {pos, freqs}
                 end)
                 |> Enum.into(%{})

  def play_dirac(_a, %{score: s} = b) when s >= 21 do
    %{b.number => b.universes}
  end

  def play_dirac(a, b) do
    @next_position[a.position]
    |> Enum.map(fn {pos, universes} ->
      {universes, %{a | position: pos, score: a.score + pos, universes: a.universes * universes}}
    end)
    |> Enum.reduce(%{}, fn {universes, new_a}, acc ->
      new_b = %{b | universes: b.universes * universes}
      Map.merge(acc, play_dirac(new_b, new_a), fn _k, v1, v2 -> v1 + v2 end)
    end)
  end

  def part2(filename \\ "input.txt") do
    [a, b] = players(filename)
    play_dirac(a, b)
  end
end
