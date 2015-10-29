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
    end
  end

  def handle_call({:move, player, column}, _from, state) do
    case ConnectFour.Board.place_token(player, column) do
      :move_accepted ->
        newstate = Map.put(state, :last_moved, player)
        {:reply, :ok, newstate}
    end
  end
end
