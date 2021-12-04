defmodule Day04 do
  @input "input.txt"
         |> File.read!()
         |> String.trim_trailing()
         |> String.split("\n\n")

  defp parse_bingo_board(str) do
    ## Returns a two-level map where numbers[row][col] = num
    numbers =
      str
      |> String.split("\n")
      |> Enum.map(&bingo_line_to_map/1)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {map, index}, acc -> Map.put(acc, index, map) end)

    ## if marks[row][col] is true, we've matched a number
    marks = %{}

    ## winning_number is the number we won with

    %{numbers: numbers, marks: marks, winning_number: nil}
  end

  defp bingo_line_to_map(line) do
    line
    |> String.trim()
    |> String.split(~r/\s+/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {n, index}, acc ->
      {i, ""} = Integer.parse(n)
      Map.put(acc, index, i)
    end)
  end

  defp enumerate_board_numbers(board) do
    Enum.flat_map(0..4, fn row ->
      Enum.map(0..4, fn col ->
        {board.numbers[row][col], row, col}
      end)
    end)
  end

  defp update_board(board, number) do
    board =
      case enumerate_board_numbers(board) |> Enum.filter(fn {n, _row, _col} -> n == number end) do
        [] ->
          board

        [{_n, row, col}] ->
          row_marks = board.marks[row] || %{}
          new_row_marks = Map.put(row_marks, col, true)
          %{board | marks: Map.put(board.marks, row, new_row_marks)}
      end

    if !board.winning_number && win?(board) do
      %{board | winning_number: number}
    else
      board
    end
  end

  defp win?(%{marks: marks} = _board) do
    winning_rows =
      Enum.filter(0..4, fn row ->
        marks[row][0] && marks[row][1] && marks[row][2] && marks[row][3] && marks[row][4]
      end)

    winning_cols =
      Enum.filter(0..4, fn col ->
        marks[0][col] && marks[1][col] && marks[2][col] && marks[3][col] && marks[4][col]
      end)

    winning_rows ++ winning_cols != []
  end

  defp win_value(board) do
    unmarked_sum =
      enumerate_board_numbers(board)
      |> Enum.filter(fn {_n, row, col} -> !board.marks[row][col] end)
      |> Enum.reduce(0, fn {n, _row, _col}, acc -> acc + n end)

    IO.inspect(unmarked_sum) * IO.inspect(board.winning_number)
  end

  ## returns value of first winner
  defp first_winner([number | rest], boards) do
    boards = Enum.map(boards, fn board -> update_board(board, number) end)

    case Enum.filter(boards, fn board -> board.winning_number == number end) do
      [] -> first_winner(rest, boards)
      [winner] -> win_value(winner)
    end
  end

  def part1 do
    [numbers_str | boards_strs] = @input

    numbers =
      numbers_str
      |> String.split(",")
      |> Enum.map(fn n ->
        {i, ""} = Integer.parse(n)
        i
      end)

    boards = Enum.map(boards_strs, &parse_bingo_board/1)

    first_winner(numbers, boards)
  end

  ## returns value of last winner
  defp last_winner([number | rest], boards, prev_winner) do
    boards = Enum.map(boards, fn board -> update_board(board, number) end)

    case Enum.filter(boards, fn board -> board.winning_number == number end) do
      [] -> last_winner(rest, boards, prev_winner)
      [winner | _] -> last_winner(rest, boards, winner)
    end
  end

  defp last_winner([], _boards, win), do: win_value(win)

  def part2 do
    [numbers_str | boards_strs] = @input

    numbers =
      numbers_str
      |> String.split(",")
      |> Enum.map(fn n ->
        {i, ""} = Integer.parse(n)
        i
      end)

    boards = Enum.map(boards_strs, &parse_bingo_board/1)

    last_winner(numbers, boards, nil)
  end
end
