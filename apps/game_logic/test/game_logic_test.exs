defmodule GameLogicTest do
  use ExUnit.Case

  alias GameLogic.{Board, Stone}

  test "gets strings" do
    # Example: diagonal stones are not solidly connected
    s1 = %Stone{x: 0, y: 0, color: :black}
    s2 = %Stone{x: 1, y: 1, color: :black}

    # Example: adjacent stones are solidly connected and are therefore strings
    s3 = %Stone{x: 2, y: 2, color: :white}
    s4 = %Stone{x: 2, y: 3, color: :white}
    s5 = %Stone{x: 3, y: 2, color: :white}
    s6 = %Stone{x: 3, y: 3, color: :white}

    b = %Board{
      size: 13,
      stones: [s1, s2, s3, s4, s5, s6]
    }

    [string1 | rest] = strings = GameLogic.get_strings(b)

    assert length(strings) == 3
    assert string1 == [s1]

    [string2 | rest] = rest
    assert string2 == [s2]

    [string3 | _] = rest
    assert string3 == [s3, s4, s5, s6]
  end

  test "#run with basic liberties" do
    # Example: single stone surrounded by enemy stones on four sides
    s1 = %Stone{x: 1, y: 2, color: :white}
    s2 = %Stone{x: 2, y: 1, color: :white}
    s3 = %Stone{x: 0, y: 1, color: :white}
    s4 = %Stone{x: 1, y: 0, color: :white}
    # No liberties
    s5 = %Stone{x: 1, y: 1, color: :black}

    # Example: corner stone surrounded by enemy stones on two sides
    # No liberties
    s6 = %Stone{x: 12, y: 0, color: :white}
    s7 = %Stone{x: 12, y: 1, color: :black}
    s8 = %Stone{x: 11, y: 0, color: :black}

    b = %Board{
      size: 13,
      stones: [s1, s2, s3, s4, s5, s6, s7, s8]
    }

    [to_remove | rest] = strings = GameLogic.run(b, s4)

    assert length(strings) == 2
    assert to_remove == [s5]

    [to_remove2 | _] = rest
    assert to_remove2 == [s6]
  end

  test "#run with strings" do
    # Example: String of stones surrounded by enemy stones
    b1 = %Stone{x: 1, y: 0, color: :black}
    b2 = %Stone{x: 2, y: 0, color: :black}
    b3 = %Stone{x: 3, y: 0, color: :black}
    b4 = %Stone{x: 4, y: 1, color: :black}
    b5 = %Stone{x: 4, y: 2, color: :black}
    b6 = %Stone{x: 3, y: 3, color: :black}
    b7 = %Stone{x: 2, y: 2, color: :black}
    b8 = %Stone{x: 0, y: 1, color: :black}
    b9 = %Stone{x: 0, y: 2, color: :black}
    b10 = %Stone{x: 0, y: 3, color: :black}
    b11 = %Stone{x: 1, y: 4, color: :black}
    b12 = %Stone{x: 2, y: 4, color: :black}

    w1 = %Stone{x: 1, y: 1, color: :white}
    w2 = %Stone{x: 2, y: 1, color: :white}
    w3 = %Stone{x: 3, y: 1, color: :white}
    w4 = %Stone{x: 3, y: 2, color: :white}
    w5 = %Stone{x: 2, y: 3, color: :white}
    w6 = %Stone{x: 1, y: 3, color: :white}
    w7 = %Stone{x: 1, y: 2, color: :white}

    b = %Board{
      size: 13,
      stones: [
        b1,
        b2,
        b3,
        b4,
        b5,
        b6,
        b7,
        b8,
        b9,
        b10,
        b11,
        b12,
        w1,
        w2,
        w3,
        w4,
        w5,
        w6,
        w7
      ]
    }

    [string | _] = strings = GameLogic.run(b, b7)

    assert length(strings) == 1
    assert length(string) == 7
  end
end
