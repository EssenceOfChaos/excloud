defmodule Excloud.Api.Server do
  @moduledoc """
  Api Server
  """
  use GenServer
  require Logger

  defstruct [
    :apiUrl,
    :authorizationToken,
    :downloadUrl,
    :recommendedPartSize,
    :bucketName
  ]

  # Module attributes #
  @url "https://api.backblazeb2.com/b2api/v2/b2_authorize_account"

  @expected_fields ~w(
    accountId authorizationToken allowed apiUrl downloadUrl
    recommendedPartSize absoluteMinimumPartSize minimumPartSize
    capabilities bucketId bucketName namePrefix
  )

  # Client
  def start_link(token \\ "") do
    GenServer.start_link(__MODULE__, token, name: __MODULE__)
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Server (callbacks)

  @impl true
  def init(token) do
    api_status = init_api_server(token)
    {:ok, api_status}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  ## Private Functions ##
  defp init_api_server(token) do
    Logger.debug(token)

    headers = [
      Authorization: "Basic #{Base.encode64(token)}",
      Accept: "Application/json; Charset=utf-8"
    ]

    case HTTPoison.get(@url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_response(body)

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:ok, %HTTPoison.Response{status_code: 401}} ->
        IO.puts("bad_auth_token!")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end

  defp process_response(body) do
    body
    |> Jason.decode!()
    |> Map.take(@expected_fields)
    |> build()

    # |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end

  defp build(attrs) do
    formatted_attrs = %{
      apiUrl: attrs["apiUrl"],
      authorizationToken: attrs["authorizationToken"],
      downloadUrl: attrs["downloadUrl"],
      recommendedPartSize: attrs["recommendedPartSize"],
      bucketName: attrs["bucketName"]
    }

    struct(__MODULE__, formatted_attrs)
  end
end
