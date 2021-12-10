defmodule Day10 do
  @openers ["(", "<", "[", "{"]
  @closers [")", ">", "]", "}"]

  ## A line is a list of openers and/or closers
  @type line :: [String.t()]

  ## A stack is a list of unclosed openers, most recent first (i.e., reverse order)
  @type stack :: [String.t()]

  @spec lines(String.t()) :: [line]
  defp lines(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints/1)
  end

  @spec validate(line, stack) :: :valid | {:incomplete, stack} | {:corrupted, String.t()}
  defp validate(line, stack \\ [])

  defp validate([], []), do: :valid

  defp validate([], stack), do: {:incomplete, stack}

  defp validate([c | rest], stack) when c in @openers do
    ## Always legal to open a collection
    validate(rest, [c | stack])
  end

  defp validate([c | _rest], []) when c in @closers do
    {:corrupted, c}
  end

  defp validate([c | rest], [opener | stack_rest]) when c in @closers do
    cond do
      opener == "<" && c == ">" -> validate(rest, stack_rest)
      opener == "(" && c == ")" -> validate(rest, stack_rest)
      opener == "[" && c == "]" -> validate(rest, stack_rest)
      opener == "{" && c == "}" -> validate(rest, stack_rest)
      :else -> {:corrupted, c}
    end
  end

  @error_values %{
    ")" => 3,
    "]" => 57,
    "}" => 1197,
    ">" => 25137
  }

  def part1(filename \\ "input.txt") do
    filename
    |> lines()
    |> Enum.map(&validate/1)
    |> Enum.filter(fn
      {:corrupted, _} -> true
      _ -> false
    end)
    |> Enum.map(fn {:corrupted, c} -> @error_values[c] end)
    |> Enum.sum()
  end

  @score_values %{
    "(" => 1,
    "[" => 2,
    "{" => 3,
    "<" => 4
  }

  @spec score_stack(stack, non_neg_integer) :: non_neg_integer
  defp score_stack(stack, score \\ 0)

  defp score_stack([], score), do: score

  defp score_stack([c | rest], score) do
    score = score * 5 + @score_values[c]
    score_stack(rest, score)
  end

  def part2(filename \\ "input.txt") do
    scores =
      filename
      |> lines()
      |> Enum.map(&validate/1)
      |> Enum.filter(fn
        {:incomplete, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:incomplete, stack} -> score_stack(stack) end)
      |> Enum.sort()

    middle_index = round(Enum.count(scores) / 2) - 1

    Enum.at(scores, middle_index)
  end
end
