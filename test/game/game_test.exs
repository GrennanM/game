defmodule Game.GameTest do
  use ExUnit.Case, async: true

  alias Game.{
    Game,
    Board
  }

  @starting_tile_value "2"
  @obstacle "x"
  @empty "_"

  describe "new/2" do
    test "default new board has size 6*6" do
      assert %Game{board: board} = Game.new()

      assert length(List.flatten(board.rows)) == 36
    end

    test "default new board has no obstacles" do
      assert %Game{board: board} = Game.new()

      obstacles = Enum.filter(List.flatten(board.rows), &(&1 == @obstacle))
      assert length(obstacles) == 0
    end

    test "default new board has a single tile of value 2" do
      assert %Game{board: board} = Game.new()

      assert Enum.filter(List.flatten(board.rows), &(&1 == @starting_tile_value)) == [
               @starting_tile_value
             ]
    end

    test "creates a board of size 1*1 with 0 obstacles" do
      assert %Game{board: board} = Game.new(1, 0)
      assert board.rows == [[@starting_tile_value]]

      obstacles = Enum.filter(List.flatten(board.rows), &(&1 == @obstacle))
      assert length(obstacles) == 0
    end

    test "creates a board of size 4*4 with 2 obstacles" do
      assert %Game{board: board} = Game.new(4, 2)

      flattened_rows = List.flatten(board.rows)
      assert length(flattened_rows) == 16

      obstacles = Enum.filter(flattened_rows, &(&1 == @obstacle))
      assert length(obstacles) == 2
    end
  end

  describe "do_move/2" do
    test "moves board to left and adds new tile if space available" do
      rows = [
        [@empty, @empty],
        [@empty, "3"]
      ]

      board = %Board{rows: rows}

      assert {:ok, %Game{board: new_board}} = Game.do_move(%Game{board: board}, :left)
      [_first, second_row] = new_board.rows

      assert hd(second_row) == "3"

      flattened_rows = List.flatten(new_board.rows)
      new_tiles = Enum.filter(flattened_rows, &(&1 == "1"))
      assert length(new_tiles) == 1
    end

    test "adds new score" do
      rows = [
        [@empty, @empty],
        ["3", "3"]
      ]

      game = %Game{board: %Board{rows: rows}, score: 3}

      assert {:ok, %Game{score: 6}} = Game.do_move(game, :left)
    end

    test "returns game over if no moves available" do
      rows = [
        ["1", "2"],
        ["3", "4"]
      ]

      game = %Game{board: %Board{rows: rows}, game_over: false}

      assert {:ok, %Game{game_over: true}} = Game.do_move(game, :left)
    end

    test "returns board unchanged if board is full but there is still a move available" do
      rows = [
        ["1", "2"],
        ["1", "4"]
      ]

      game = %Game{board: %Board{rows: rows}}

      assert {:ok, %Game{board: %Board{rows: ^rows}}} = Game.do_move(game, :left)
    end

    test "returns game won if score is 2048" do
      rows = [
        ["2048", "2"],
        ["1", @empty]
      ]

      game = %Game{board: %Board{rows: rows}, game_won: false, game_over: false}

      assert {:ok, %Game{game_over: true, game_won: true}} = Game.do_move(game, :left)
    end

    test "shifts board to right" do
      rows = [
        ["4", @empty],
        ["3", @empty]
      ]

      game = %Game{board: %Board{rows: rows}}

      assert {:ok, %Game{board: %Board{rows: new_rows}}} = Game.do_move(game, :right)
      [first_row, second_row] = new_rows

      assert List.last(first_row) == "4"
      assert List.last(second_row) == "3"
    end

    test "shifts board up" do
      rows = [
        ["2", @empty],
        ["3", "4"]
      ]

      game = %Game{board: %Board{rows: rows}}

      assert {:ok, %Game{board: %Board{rows: new_rows}}} = Game.do_move(game, :up)
      assert [["2", "4"], ["3", "1"]] = new_rows
    end

    test "shifts board down" do
      rows = [
        ["2", "4"],
        ["3", @empty]
      ]

      game = %Game{board: %Board{rows: rows}}

      assert {:ok, %Game{board: %Board{rows: new_rows}}} = Game.do_move(game, :down)
      assert [["2", "1"], ["3", "4"]] = new_rows
    end
  end
end
