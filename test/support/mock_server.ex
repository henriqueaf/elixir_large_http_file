defmodule HTTPStream.MockServer do
  use Plug.Router
  plug :match
  plug :dispatch
  plug Plug.Parsers, parsers: [:json],
                    pass:  ["text/*"],
                    json_decoder: Poison

  get "/downloads/httpstream/numbers.txt" do
    {:ok, file_content} = File.read("test/fixtures/numbers.txt")
    Plug.Conn.send_resp(conn, 200, file_content)
  end
end
