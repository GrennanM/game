defmodule Game.Game do
  alias Game.Board
  alias Game.Game

  @type t() :: %__MODULE__{}

  @default_board_size 6
  @default_obstacle_count 0

  defstruct [:board, game_over: false, game_won: false, score: 0]

  @doc """
  Create new game with board of given size and given number of obstacles randomly positioned.
  """
  @spec new(non_neg_integer, non_neg_integer) :: Game.t()
  def new(size \\ @default_board_size, obstacle_count \\ @default_obstacle_count) do
    if obstacle_count >= size ** 2 do
      Game.new()
    else
      %Game{board: Board.new(size, obstacle_count)}
    end
  end

  @doc """
  Completes full move in the direction given.
  """
  @spec do_move(Game.t(), :left | :right | :up | :down) ::
          {:ok, Game.t()} | {:ok, {:game_over, Game.t()}} | {:ok, {:game_won, Game.t()}}
  def do_move(%Game{board: %Board{rows: rows} = board} = game, direction) do
    rows = Board.move(rows, direction)
    score = Board.calculate_score(rows)

    board = %{board | rows: rows}
    game = %{game | board: board, score: score}

    cond do
      score_is_2048?(score) ->
        {:ok, %{game | game_won: true, game_over: true}}

      Board.has_space_available?(board.rows) ->
        {:ok, %{game | board: Board.add_new_tile(board)}}

      Board.no_move_available?(board) ->
        {:ok, %{game | game_won: false, game_over: true}}

      true ->
        {:ok, game}
    end
  end

  defp score_is_2048?(score), do: score == 2048
end
