defmodule LightRequester.Requester do

  def request_action() do
    receive do

      {:inspect, content} -> handleContent(content)

      {:request, url, req_id} -> handleRequest(url, req_id)

      {:exit} -> {:ok}

    end
  end

  def handleContent(content) do
    IO.inspect(content)
    request_action()
  end

  def handleRequest(url, req_id) do

    req_time = System.system_time(:milliseconds)
    response = HTTPotion.get url
    resp_time = System.system_time(:milliseconds)

    send(:response_receiver, {:response, response, req_time, resp_time, req_id})

    request_action()
  end
end
