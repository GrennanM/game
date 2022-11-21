defmodule Game.BoardsTest do
  use ExUnit.Case, async: true

  alias Game.Board

  # obstacle placeholder
  @obstacle "x"

  # empty tile placeholder
  @empty "_"

  @new_tile_value "1"

  describe "add_new_tile/1" do
    test "adds one new tile when many spaces available" do
      board = %Board{rows: [[@empty, @empty], [@empty, @empty]]}

      %Board{rows: new_rows} = Board.add_new_tile(board, @new_tile_value)
      flattened_rows = List.flatten(new_rows)

      new_tiles = Enum.filter(flattened_rows, &(&1 == @new_tile_value))
      assert length(new_tiles) == 1
    end

    test "adds one new tile when only one space available" do
      board = %Board{rows: [[@empty, "8"], ["4", "2"]]}

      %Board{rows: new_rows} = Board.add_new_tile(board, @new_tile_value)
      flattened_rows = List.flatten(new_rows)

      new_tiles = Enum.filter(flattened_rows, &(&1 == @new_tile_value))
      assert length(new_tiles) == 1
    end
  end

  describe "shift_row/1" do
    test "moves row without obstacle" do
      rows = [
        {[@empty, "2"], ["2", @empty]},
        {[@empty, "2", "2"], ["2", "2", @empty]},
        {[@empty, "2", @empty, @empty, "2", @empty], ["2", "2", @empty, @empty, @empty, @empty]},
        {["2"], ["2"]}
      ]

      Enum.each(rows, fn {input, expected} ->
        assert expected == Board.shift_row(input)
      end)
    end

    test "moves row with obstacle" do
      rows = [
        {[@empty, @obstacle, "2"], [@empty, @obstacle, "2"]},
        {[@empty, "2", @obstacle], ["2", @empty, @obstacle]},
        {["2", @obstacle, @empty, "2"], ["2", @obstacle, "2", @empty]},
        {["2", @obstacle, @empty, "2", @obstacle, @empty, "2"],
         ["2", @obstacle, "2", @empty, @obstacle, "2", @empty]},
        {[@obstacle], [@obstacle]}
      ]

      Enum.each(rows, fn {input, expected} ->
        assert expected == Board.shift_row(input)
      end)
    end

    test "can handle numbers greater than 1 digit" do
      assert ["12", @empty] == Board.shift_row([@empty, "12"])
      assert ["123", "2", @empty, @empty] == Board.shift_row([@empty, "123", @empty, "2"])
      assert ["1234", "24", "2", @empty] == Board.shift_row([@empty, "1234", "24", "2"])
    end
  end

  describe "merge/1" do
    test "merges row without obstacle" do
      rows = [
        {["2", "2"], ["4", @empty]},
        {["2", "2", "2"], ["4", @empty, "2"]},
        {["2", "4"], ["2", "4"]},
        {["2", @empty, "2"], ["2", @empty, "2"]},
        {["2", "2", "2", "2"], ["4", @empty, "4", @empty]}
      ]

      Enum.each(rows, fn {input, expected} ->
        assert expected == Board.merge(input)
      end)
    end

    test "merges row with obstacle" do
      rows = [
        {["2", @obstacle, "2"], ["2", @obstacle, "2"]},
        {["2", @obstacle, "2", "2"], ["2", @obstacle, "4", @empty]},
        {["2", "2", "2", @obstacle, "2"], ["4", @empty, "2", @obstacle, "2"]},
        {["2", "2", "2", "2", @obstacle], ["4", @empty, "4", @empty, @obstacle]}
      ]

      Enum.each(rows, fn {input, expected} ->
        assert expected == Board.merge(input)
      end)
    end
  end

  describe "shift_and_compress/1" do
    test "shifts and compresses row correctly" do
      rows = [
        {["2", @obstacle, "2"], ["2", @obstacle, "2"]},
        {["2", @obstacle, "2", "2"], ["2", @obstacle, "4", @empty]},
        {["2", "2", "2", @obstacle, "2"], ["4", "2", @empty, @obstacle, "2"]},
        {["2", "2", "2", "2", @obstacle], ["4", "4", @empty, @empty, @obstacle]},
        {["2", "2", "2", @obstacle, "4", "1"], ["4", "2", @empty, @obstacle, "4", "1"]},
        {["1", "2", @obstacle, "1"], ["1", "2", @obstacle, "1"]},
        {[@empty, @empty], [@empty, @empty]}
      ]

      Enum.each(rows, fn {input, expected} ->
        assert expected == Board.shift_and_compress(input)
      end)
    end
  end
end
