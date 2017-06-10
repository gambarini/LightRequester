defmodule LightRequester.RequesterApiPlug do
  use Plug.Router
  require Logger

  plug :match
  plug Plug.Parsers, parsers: [:json],
                   pass:  ["application/json"],
                   json_decoder: Poison
  plug :dispatch

  put "/requester/:number" do
    Logger.info(number)
    LightRequester.spawn_requesters(Integer.parse(number))

    send_json_resp(conn, 200, %{:totalRquesters => LightRequester.count_requesters()})
  end

  defp send_json_resp(conn, code, payload) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(code, Poison.encode!(payload))
  end
end
