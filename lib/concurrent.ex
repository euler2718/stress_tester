defmodule Concurrent do
  defstruct url: nil, xApiKey: nil, headers: [{"Content-type", "application/json"}], filename: nil, update: true
  ## DEV
  @url "https://model.api-dev.cfins.io/iqRating"
  @xApiKey "8KGLKf6GD2pm8pOeoxjS53pg4JeDxdZ3ZYjLBgS6"

  ## QA
  # @url "https://model.api-qa.cfins.io/iqRating"
  # @xApiKey "9MCLUydi4R8hELmAVgmtM1EESalkybmC7kJZueUe"

  ## ALL
  @headers [{"Content-type", "application/json"}, {"x-api-key", @xApiKey}]
  @filename "lib/request_body.json"


  @moduledoc """
  Documentation for Concurrent.

  use 
  """

  @doc """
  Hello world.

  ## Examples

      iex> Concurrent.hello()
      :world

  """

  def sysCheck do
    {:ok, path} = File.cwd
    IO.puts(path)
  end

  def createTasks(num) do
    time = DateTime.utc_now() |> DateTime.to_string
    IO.puts(time)
    c = setDefaults() |> updateHeaders
    body = genBody(c.filename)
    Enum.map(1..num, fn(_) -> Task.async(fn -> sendRequest(c, body) end) end)
    |> Enum.map(fn(task) -> Task.await(task, 145000) end) # 145000 == Timeout in milliseconds
  end

  def createTasks(%Concurrent{filename: filename} = c, num) do
    time = DateTime.utc_now() |> DateTime.to_string
    IO.puts(time)
    c = cond do
      c.update ->
        updateHeaders(c)
      true ->
        c
    end
    body = genBody(filename)
    ## check out Enum.reduce here... https://stackoverflow.com/questions/42330425/how-to-await-multiple-tasks-in-elixir/42330810#42330810
    Enum.map(1..num, fn(_) -> Task.async(fn -> sendRequest(c, body) end) end)
    |> Enum.map(fn(task) -> Task.await(task, 145000) end) # 145000 == Timeout in milliseconds
  end

  defp setDefaults do
    %Concurrent{
      :url => @url,
      :headers => @headers,
      :filename => @filename,
      :xApiKey => @xApiKey
    }
  end

  defp updateHeaders(%Concurrent{} = c) do
    Map.update!(c, :headers, &([{"x-api-key", c.xApiKey} | &1]))
  end

  defp genBody(filename) do
    {:ok, body} = File.read(filename)
    String.replace(body, ["\r", "\n", " "], "")
  end


  defp sendReqWrapper(c, body) do
    time = :timer.tc(fn(x,y) -> sendRequest(x,y) end, [c, body]) |> elem(0)
    IO.puts("hello")
    IO.puts(time)
  end

  defp sendRequest(%Concurrent{url: url, headers: headers}, bbb) do
    # could add timer here...
    %HTTPoison.Response{body: _body, status_code: status_code} = 
    try do
      HTTPoison.post!(url, bbb, headers, [timeout: 100_000, recv_timeout: 100_000])
    rescue
      err in HTTPoison.Error ->
        IO.inspect(err)
        %HTTPoison.Response{body: bbb, status_code: 504}
    end
    # IO.inspect(body)
    # IO.puts(status_code)
    # mappedBody = body |> Poison.decode!
    time = DateTime.utc_now() |> DateTime.to_string
    case status_code do
      200 ->
        # time = mappedBody["input"]["requestContext"]["requestTime"]
        IO.puts("SUCCESS #{time}")
        # IO.puts(body)
      504 ->
        # time = DateTime.utc_now() |> DateTime.to_string
        IO.puts "TIMEOUT ERROR #{status_code} #{time}"
      _ ->
        # time = DateTime.utc_now() |> DateTime.to_string
        IO.puts "Error #{status_code} #{time}"
    end
  end
end