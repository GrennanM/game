defmodule Game.Board do
  use Ecto.Schema

  alias Game.Board

  @type t() :: %__MODULE__{}

  @empty_tile_value "_"
  @obstacle_value "x"
  @new_tile_value "1"
  @starting_tile_value "2"

  defstruct [:rows, :obstacle_count]

  @spec new(non_neg_integer, non_neg_integer) :: Game.Board.t()
  def new(size, obstacle_count) do
    %Board{rows: create_empty_rows(size), obstacle_count: obstacle_count}
    |> add_obstacles()
    |> add_new_tile(@starting_tile_value)
  end

  @doc """
  Moves a list of rows in given direction, merging side-by-side rows of equal value.
  """
  @spec move(list, :down | :left | :right | :up) :: list
  def move(rows, :left), do: Enum.map(rows, &shift_and_compress/1)

  def move(rows, :right) do
    rows
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&shift_and_compress/1)
    |> Enum.map(&Enum.reverse/1)
  end

  def move(rows, :up) do
    rows
    |> transpose()
    |> Enum.map(&shift_and_compress/1)
    |> transpose()
  end

  def move(rows, :down) do
    rows
    |> transpose()
    |> move(:right)
    |> transpose()
  end

  @doc """
  Shifts row to the left merging matching side-by-side tiles.
  """
  def shift_and_compress(row) do
    row
    |> shift_row()
    |> merge()
    |> shift_row()
  end

  @doc """
  Shifts a row to the left taking into account obstacles.

  A tile can't move past an obstacle.

  Algorithm:
    * Split row at obstacle
    * Move tiles to left in each list
    * Pad each list to original length
    * Re-join lists
  """
  def shift_row(row) do
    split_row = row |> Enum.join(".") |> String.split(@obstacle_value)

    # store original lengths of each list
    lengths = Enum.map(split_row, &String.length/1)

    split_row
    |> Enum.map(&String.replace(&1, @empty_tile_value, ""))
    |> Enum.zip(lengths)
    |> Enum.map(fn {str, length} ->
      pad_total = 2 * length - String.length(str)
      String.pad_trailing(str, pad_total, "." <> @empty_tile_value)
    end)
    |> Enum.join("." <> @obstacle_value)
    |> String.split(".", trim: true)
  end

  @doc """
  Merge side-by-side tiles which have the same value.
  """
  @spec merge(list) :: list
  def merge(row)
  def merge([]), do: []

  def merge([v1, v2 | tail]) when v1 == v2 and v1 not in ["x", "_"] do
    new_value = (String.to_integer(v1) + String.to_integer(v2)) |> Integer.to_string()
    [new_value, "_" | merge(tail)]
  end

  def merge([v1 | tail]), do: [v1 | merge(tail)]

  @spec calculate_score(list) :: Integer.t()
  def calculate_score(rows) do
    rows
    |> List.flatten()
    |> Enum.reject(&(&1 in [@obstacle_value, @empty_tile_value]))
    |> Enum.map(&String.to_integer/1)
    |> Enum.max()
  end

  @doc """
  Adds new tile to board in random free position.
  """
  @spec add_new_tile(Board.t(), String.t()) :: Board.t()
  def add_new_tile(%Board{rows: rows} = board, tile_value \\ @new_tile_value) do
    empty_position =
      board
      |> get_all_coordinates()
      |> Enum.zip(List.flatten(rows))
      |> Enum.filter(fn {_, val} -> val == @empty_tile_value end)
      |> Enum.random()
      |> elem(0)

    rows = put_value_at_position(board, empty_position, tile_value)
    %{board | rows: rows}
  end

  def no_move_available?(%Board{rows: rows}) do
    possible_boards = Enum.map([:left, :right, :up, :down], &move(rows, &1))
    Enum.all?(possible_boards, &board_is_full?/1)
  end

  def has_space_available?(rows), do: !board_is_full?(rows)

  defp add_obstacles(board) do
    {_, new_board} =
      board
      |> get_all_coordinates()
      |> Enum.take_random(board.obstacle_count)
      |> Enum.map_reduce(board, fn position, board ->
        rows = put_value_at_position(board, position, @obstacle_value)
        {nil, Map.put(board, :rows, rows)}
      end)

    new_board
  end

  defp create_empty_rows(n) do
    @empty_tile_value
    |> List.duplicate(n)
    |> List.duplicate(n)
  end

  defp put_value_at_position(board, [row_index, col_index], value) do
    board.rows
    |> Enum.at(row_index)
    |> List.replace_at(col_index, value)
    |> (&List.replace_at(board.rows, row_index, &1)).()
  end

  defp get_all_coordinates(board) do
    l = length(board.rows)
    for row <- 0..(l - 1), col <- 0..(l - 1), into: [], do: [row, col]
  end

  defp board_is_full?(rows), do: !Enum.any?(List.flatten(rows), &(&1 == @empty_tile_value))

  defp transpose([]), do: []
  defp transpose([[] | _]), do: []

  defp transpose(x), do: [Enum.map(x, &hd/1) | transpose(Enum.map(x, &tl/1))]
end
