defmodule HTTPStream.Supevisor do
  use Supervisor
  alias HTTPStream.{Receiver}

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  # It starts automatically HTTPStream.Receiver GenServer.
  # So you can call the HTTPStream.Receiver methods without call start_link before:

  def init(_) do
    children = [
      worker(Receiver, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
