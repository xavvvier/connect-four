defmodule ConnectFour.Game do
  use GenServer

  @registered_name ConnectFourGame

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [name: @registered_name])
  end

  def print_board() do
    ConnectFour.Board.print
  end
end
