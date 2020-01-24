defmodule HTTPStream do
  @moduledoc """
  A module that uses Elixir's Stream to download a large file over an
  HTTP request very fast.
  """
  use Application
  alias HTTPStream.{Receiver, MockServer}

  def start(_type, _args) do
    env_children = case Mix.env do
      :test -> [
        Plug.Cowboy.child_spec(scheme: :http, plug: MockServer, port: 8081)
      ]
      _ -> []
    end

    children = env_children ++ [Receiver]

    opts = [strategy: :one_for_one, name: HTTPStream.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Download a file by a given URL.

  ## Examples
    iex> image_url = "https://www.spacetelescope.org/static/archives/images/original/heic0506a.tif"
    iex> image_url |> HTTPStream.get |> StreamGzip.gzip |> Stream.into(File.stream!("/workspace/image.tif.gz")) |> Stream.run
    :ok
  """
  def get(url) do
    Receiver.process(url)
  end
end
