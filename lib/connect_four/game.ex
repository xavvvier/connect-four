defmodule ConnectFour.Game do
  use GenServer

  @registered_name ConnectFourGame

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [name: @registered_name])
  end

  def print_board() do
    ConnectFour.Board.print
  end

  def move(player, column) do
    case GenServer.call(@registered_name, {:move, player, column}) do
      :ok -> "Successful move for #{player} player in column #{column}"
      :full -> "Column #{column} is full. Please choose another."
      :wrong_player -> "It's not your turn!"
      :winner -> "Player #{player} wins"
    end
  end

  def handle_call({:move, player, _column}, _from, %{last_moved: player}= state) do
    {:reply, :wrong_player, state}
  end

  def handle_call({:move, player, column}, _from, state) do
    case ConnectFour.Board.place_token(player, column) do
      :move_accepted ->
        newstate = Map.put(state, :last_moved, player)
        {:reply, :ok, newstate}
      :column_full ->
        {:reply, :full, state}
      :winner ->
        {:reply, :winner, state}
    end
  end
end
