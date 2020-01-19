defmodule HTTPStream.Receiver do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def process(url) do
    Stream.resource(
      fn -> start_function(url) end,
      &next_function/1,
      &after_function/1
    )
  end

  defp start_function(url) do
    HTTPoison.get!(
      url,
      %{},
      [stream_to: self(), async: :once]
    )
  end

  defp next_function(%HTTPoison.AsyncResponse{id: id} = resp) do
    receive do
      %HTTPoison.AsyncStatus{id: ^id, code: code} ->
        IO.inspect(code, label: "Status code")
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncHeaders{id: ^id, headers: headers} ->
        IO.inspect(headers, label: "Headers")
        HTTPoison.stream_next(resp)
        {[], resp}
      %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
        HTTPoison.stream_next(resp)
        {[chunk], resp} # all the [chunck] are caught by Stream.into() and written on "image.tif"
      %HTTPoison.AsyncEnd{id: ^id} ->
        {:halt, resp}
    after
      5_000 -> raise "receive timeout"
    end
  end

  defp after_function(resp) do
    IO.puts "finalizou"
    :hackney.stop_async(resp.id)
  end

  @impl true
  def init(init_args) do
    {:ok, init_args}
  end
end