defmodule Day24 do
  @type alu :: %{w: integer, x: integer, y: integer, z: integer}

  @type(
    instruction :: {:inp, atom} | {:add, atom, atom | integer} | {:mul, atom, atom | integer},
    {:div, atom, atom | integer} | {:mod, atom, atom | integer} | {:eql, atom, atom | integer}
  )

  @type cpu :: %{alu: alu, instructions: [instruction], input: [integer]}

  def alu do
    %{w: 0, x: 0, y: 0, z: 0}
  end

  def instructions(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_instruction/1)
  end

  def parse_instruction(str) do
    tokens =
      str
      |> String.split(" ")
      |> Enum.map(fn x ->
        case Integer.parse(x) do
          {i, ""} -> i
          _ -> String.to_existing_atom(x)
        end
      end)

    case tokens do
      [x, y] -> {x, y}
      [x, y, z] -> {x, y, z}
    end
  end

  def execute(alu, instructions, input)

  def execute(alu, [], _input), do: alu

  def execute(alu, [{:inp, target} | rest], [input | restinput]) do
    alu
    |> Map.put(target, input)
    |> execute(rest, restinput)
  end

  def execute(alu, [{:add, target, arg} | rest], input) do
    value = if is_number(arg), do: arg, else: alu[arg]
    alu |> Map.put(target, alu[target] + value) |> execute(rest, input)
  end

  def execute(alu, [{:mul, target, arg} | rest], input) do
    value = if is_number(arg), do: arg, else: alu[arg]
    alu |> Map.put(target, alu[target] * value) |> execute(rest, input)
  end

  def execute(alu, [{:div, target, arg} | rest], input) do
    value = if is_number(arg), do: arg, else: alu[arg]
    alu |> Map.put(target, div(alu[target], value)) |> execute(rest, input)
  end

  def execute(alu, [{:mod, target, arg} | rest], input) do
    value = if is_number(arg), do: arg, else: alu[arg]
    alu |> Map.put(target, rem(alu[target], value)) |> execute(rest, input)
  end

  def execute(alu, [{:eql, target, arg} | rest], input) do
    value = if is_number(arg), do: arg, else: alu[arg]
    result = if alu[target] == value, do: 1, else: 0
    alu |> Map.put(target, result) |> execute(rest, input)
  end

  ## Nah
  def part1(filename \\ "input.txt") do
    instructions = instructions(filename)

    for a <- 9..1,
        b <- 9..1,
        c <- 9..1,
        d <- 9..1,
        e <- 9..1,
        f <- 9..1,
        g <- 9..1,
        h <- 9..1,
        i <- 9..1,
        j <- 9..1,
        k <- 9..1,
        l <- 9..1,
        m <- 9..1,
        n <- 9..1 do
      input = [a, b, c, d, e, f, g, h, i, j, k, l, m, n]

      alu =
        execute(alu(), instructions, input)
        |> IO.inspect()

      if alu.z == 0, do: throw(Enum.join(input, ""))
    end
  end

  """
  repeated code block:
  inp w
  mul x 0
  add x z
  mod x 26
  div z 26 ; only if YY <= 0
  div z 1
  add x 11 ; XX
  eql x w
  eql x 0
  ; x is 1 if w != (XX + rem(z, 26))
  mul y 0
  add y 25
  mul y x
  add y 1
  mul z y
  mul y 0
  add y w
  add y 6 ; YY
  mul y x
  add z y

  XX and YY:
  11  6
  11  12
  15  8
  -11 7  div
  15  7
  15  12
  14  2
  -7  15 div
  12  4
  -6  5 div
  -10 12 div
  -15 11 div
  -9  13 div
  0   7 div

  pseudocode:

  w = input()
  x = (w != (XX + rem(z, 26))) ? 1 : 0;

  if XX <= 0
    z = div(z, 26);       // POPPING Z FROM STACK
  end

  if x == 1
    z = z * 26;           // PUSHING CURRENT Z ONTO STACK
    z = z + w + YY;       // equivalent to z = w + YY for if statement
  end

  iter 1: 11 6, z = w1 + 6
  iter 2: 11 12, z = w2 + 12, zs = [w1 + 6]
  iter 3: 15 8, z = w3 + 8, zs = [w2 + 12, w1 + 6]
  iter 4: -11 7, w4 + 11 == rem(w3+8, 26), zs = [w2 + 12, w1 + 6]
  iter 5: 15 7, z = w5 + 7, zs = [w2+12, w1+6]
  iter 6: 15 12, z = w6 + 12, zs = [w5 + 7, w2+12, w1+6]
  iter 7: 14 2, z = w7 + 2, zs = [w6 + 12, w5 + 7, w2+12, w1+6]
  iter 8: -7 15,  w8 + 7 = rem(w7 + 2, 26)   zs = [w6 + 12, w5 + 7, w2+12, w1+6]
  iter 9: 12 4, z = w9 + 4, zs = [w6 + 12, w5 + 7, w2+12, w1+6]
  iter 10: -6 5, w10 + 6 = rem(w9+4, 26) zs = [w6 + 12, w5 + 7, w2+12, w1+6]
  iter 11: -10 12, w11 + 10 = rem(w6+12, 26) zs = [w5 + 7, w2+12, w1+6]
  iter 12: -15 11, w12 + 15 = rem(w5+7, 26) zs = [w2+12, w1+6]
  iter 13: -9 13, w13 + 9 = rem(w2+12, 26)  zs = [w1+6]
  iter 14: 0 7, w14 = w1 + 6

  w4 + 3 = w3    ; w3 = 9, w4 = 6    w3 = 4, w4 = 1
  w8 + 5 = w7    ; w7 = 9, w8 = 4    w7 = 6, w8 = 1
  w10 + 2 = w9   ; w9 = 9, w10 = 7   w9 = 3, w10 = 1
  w11 = w6 + 2   ; w6 = 7, w11 = 9   w6 = 1, w11 = 3
  w12 + 8 = w5   ; w12 = 1, w5 = 9   w12 = 1, w5 = 9
  w13 = w2 + 3   ; w2 = 6, w13 = 9   w2 = 1, w13 = 4
  w14 = w1 + 6   ; w1 = 3, w14 = 9   w1 = 1, w14 = 7

  digits:

  36969794979199
  11419161313147
  """
end
