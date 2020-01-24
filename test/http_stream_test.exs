defmodule HTTPStreamTest do
  use ExUnit.Case
  alias HTTPStream.{Receiver}
  # doctest HTTPStream

  test "sum the text file" do
    text_url = Application.get_env(:http_stream, :api_base_url) <> "/downloads/httpstream/numbers.txt"

    sum = text_url
    |> HTTPStream.get()
    |> Receiver.lines()
    |> Stream.map(fn line ->
      case Integer.parse(line) do
        {num, _} -> num
        :error -> 0
      end
    end)
    |> Enum.sum()

    assert sum == 22487
  end
end
