defmodule ConnectFour.Space do
  
  def start_link({row,column}) do
    name = String.to_atom("R#{row}C#{column}")
    Agent.start_link(fn -> Empty end, [ name: name ])    
  end
end
