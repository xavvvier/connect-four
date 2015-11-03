defmodule ConnectFour.Board do
  use Supervisor

  @registered_name ConnectFourBoard
  @last_row 6
  @last_column 7

  def start_link() do
    Supervisor.start_link(__MODULE__, :no_args, [name: @registered_name])
  end

  def init(:no_args) do
    children = 
      for t <- spaces do
        worker(ConnectFour.Space, [t], id: t)
      end
    supervise(children, strategy: :one_for_one)
  end

  def place_token(player, col) do
    if is_full?(col) do
      :column_full
    else
      row = first_empty(col)
      place_token(player, row, col)
    end
  end

  def place_token(player, row, col) do
    agent_name(row, col)
    |> Process.whereis
    |> Agent.update(fn _state -> player end)
    if winner?(row,col) do
      :winner
    else
      :move_accepted
    end
  end

  def winner?(row, col) do
    status = space_status(row, col)
    column_winner?(status, row, col,1) or #Count the actual space and search downwards
    row_winner(status, row, 1, 0) or #Start the search in column 1 with zero ocurrences
    diagonal_winner(status, row, col)
  end

  def row_winner(_, _, _, 4), do: true
  def row_winner(_, _, col, _) when col > @last_column, do: false
  def row_winner(player, row, col, count) do
    status = space_status(row, col)
    if status == player do
      row_winner(player, row, col+1, count+1)
    else
      row_winner(player, row, col+1, 0)
    end
  end

  def diagonal_winner(player, row, col) do
    {bl_row, bl_col} = bottom_left(row, col) #Start the search in the bottom-left space
    {br_row, br_col} = bottom_right(row, col) #Start the search inn the bottom-right space
    diagonal_winner_bl_tr(player, bl_row, bl_col, 0) or diagonal_winner_br_tl(player, br_row, br_col, 0)
  end

  @doc "Search a winner in bottom-left to top-right direction"
  def diagonal_winner_bl_tr(_, _, _, 4), do: true
  def diagonal_winner_bl_tr(player, row, col, count) do
    case space_status(row, col) do
      ^player -> diagonal_winner_bl_tr(player,row+1, col+1, count+1)
      nil    -> false
      _      -> diagonal_winner_bl_tr(player,row+1, col+1, 0)
    end
  end

  @doc "Search a winner in bottom-right to top-left direction"
  def diagonal_winner_br_tl(_, _, _, 4), do: true
  def diagonal_winner_br_tl(player, row, col, count) do
    case space_status(row, col) do
      ^player -> diagonal_winner_br_tl(player, row+1, col-1, count+1)
      nil    -> false
      _      -> diagonal_winner_br_tl(player, row+1, col-1, 0)
    end
  end

  def bottom_left(1,col), do: {1, col}
  def bottom_left(row, 1), do: {row, 1}
  def bottom_left(row, col) do
    bottom_left(row-1, col-1)
  end

  def bottom_right(1, col), do: {1, col}
  def bottom_right(row, col) do
    case col do
      @last_column -> {row, col}
      _ -> bottom_right(row-1, col+1)
    end
  end

  def column_winner?(_, _, _, 4), do: true
  def column_winner?(_, 1, _, _), do: false
  def column_winner?(player, row, col, count) do
    status_below = space_status(row-1,col)
    if status_below == player do
      column_winner?(player, row-1, col, count+1)
    else
      false
    end
  end

  def is_full?(col) do
    space_status(@last_row, col) != Empty
  end

  def first_empty(col) do
    first_empty(1, col)
  end

  def first_empty(row, col) do
    if empty_space?(row,col) do
      row
    else
      first_empty(row+1, col)
    end
  end

  def space_status(row, col) when row < 1 or row > @last_row or col < 1 or col > @last_column do
    nil
  end
  def space_status(row, col) do
    agent_name(row, col)
    |> Process.whereis
    |> Agent.get(&(&1))
  end

  def empty_space?(row, col) do
    space_status(row, col)
    |> is_empty?
  end

  def is_empty?(val) do
    val == Empty
  end

  def spaces do
    for row <- 1..@last_row, column <- 1..@last_column, do: {row, column}
  end

  def print do
    for row <- @last_row..1, do: print_columns(row)
  end

  def print_columns(row) do
    for col <- 1..@last_column, do: print_space(row, col)
    IO.write "\n"
  end

  def print_space(row, col) do
    space_status(row,col)
    |> convert_for_display
    |> IO.write
  end

  def convert_for_display(agent_state) do
    case agent_state do
      Empty -> "[ ]"
      :red -> "[R]"
      :black -> "[B]"
      _ -> "[?]"
    end
  end

  def agent_name(row, col) do
    String.to_atom("R" <> Integer.to_string(row) <> "C" <> Integer.to_string(col))
  end
end
