defmodule HTTPStream do
  @moduledoc """
  A module that uses Elixir's Stream to download a large file over an
  HTTP request very fast.
  """
  use Application
  alias HTTPStream.{Receiver}

  def start(_type, _args) do
    HTTPStream.Supevisor.start_link
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
