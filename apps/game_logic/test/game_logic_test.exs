defmodule GameLogicTest do
  use ExUnit.Case

  alias GameLogic.{Board, Stone}

  test "gets linear chains" do
    s1 = %Stone{x: 0, y: 0, color: :black}
    s2 = %Stone{x: 1, y: 1, color: :white}
    s3 = %Stone{x: 2, y: 2, color: :white}
    s4 = %Stone{x: 3, y: 3, color: :white}

    b = %Board{
      size: 13,
      stones: [s1, s2, s3, s4]
    }

    [b | _] = chains = GameLogic.get_chains(b)

    assert length(chains) == 2
    assert b == [s1]

    w = List.last(chains)
    assert length(w) == 3
    assert w == [s2, s3, s4]
  end

  test "gets circular chains" do
    s1 = %Stone{x: 1, y: 2, color: :white}
    s2 = %Stone{x: 2, y: 1, color: :white}
    s3 = %Stone{x: 0, y: 1, color: :white}
    s4 = %Stone{x: 1, y: 0, color: :white}

    b = %Board{
      size: 13,
      stones: [s1, s2, s3, s4]
    }

    [c | _] = chains = GameLogic.get_chains(b)

    assert length(chains) == 1
    assert c == [s3, s4, s1, s2]
  end

  test "#run with basic liberties" do
    s1 = %Stone{x: 1, y: 2, color: :white}
    s2 = %Stone{x: 2, y: 1, color: :white}
    s3 = %Stone{x: 0, y: 1, color: :white}
    s4 = %Stone{x: 1, y: 0, color: :white}
    s5 = %Stone{x: 1, y: 1, color: :black} # No liberties

    s6 = %Stone{x: 12, y: 0, color: :white} # No liberties
    s7 = %Stone{x: 12, y: 1, color: :black}
    s8 = %Stone{x: 11, y: 0, color: :black}

    b = %Board{
      size: 13,
      stones: [s1, s2, s3, s4, s5, s6, s7, s8]
    }

    [to_remove | rest] = chains = GameLogic.run(b)

    assert length(chains) == 2
    assert to_remove == [s5]

    [to_remove2 | _] = rest
    assert to_remove2 == [s6]
  end
end
