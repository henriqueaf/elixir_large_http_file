defmodule HTTPStream.Receiver do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(init_args) do
    {:ok, init_args}
  end
end