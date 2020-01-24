defmodule HTTPStream.Receiver do
  use GenServer

  def start_link(_opts) do
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
        IO.inspect(chunk, label: "Chunk")
        HTTPoison.stream_next(resp)
        {[chunk], resp} # all the [chunck] are caught by Stream.into() and written on "image.tif"
      %HTTPoison.AsyncEnd{id: ^id} ->
        {:halt, resp}
    after
      5_000 -> raise "receive timeout"
    end
  end

  defp after_function(resp) do
    :hackney.stop_async(resp.id)
  end

  def lines(enum), do: lines(enum, :string_split)

  defp lines(enum, :string_split) do
    enum
    |> Stream.transform("", fn 
      :end, acc -> 
        {[acc],""}
      chunk, acc ->
        [last_line | lines] = 
          String.split(acc <> chunk,"\n")
          |> Enum.reverse()
        {Enum.reverse(lines), last_line}
    end)
  end

  # def lines(enum), do: lines(enum, :next_lines)

  # def lines(enum, :next_lines) do
  #   enum
  #   |> Stream.transform("", &next_lines/2)
  # end

  # defp next_lines(:end, prev), do: {[prev], ""}
  # defp next_lines(chunk, current_line) do
  #   # :erlang.garbage_collect()
  #   next_lines(chunk, current_line, [])
  # end

  # defp next_lines(<<"\n"::utf8, rest::binary>>, current_line, lines) do
  #   next_lines(rest, "", [current_line <> "\n" | lines])  
  # end

  # defp next_lines(<<c::utf8, rest::binary>>, current_line, lines) do
  #   next_lines(rest, <<current_line::binary, c::utf8>>, lines)
  # end

  # defp next_lines(<<>>, current_line, lines) do
  #   {Enum.reverse(lines), current_line}
  # end

  @impl true
  def init(init_args) do
    {:ok, init_args}
  end
end