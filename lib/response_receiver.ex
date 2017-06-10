defmodule LightRequester.ResponseReceiver do
  require Logger
  def receive_responses() do
    Process.register(self(), :response_receiver)

    :ets.new(:responses_store, [:duplicate_bag, :protected, :named_table])

    process_response()
  end

  def process_response() do
    receive do
      {:response ,response, req_time, resp_time, req_id} -> process_response(response, req_time, resp_time, req_id)
    end
    process_response()
  end

  def process_response(response, req_time, resp_time, req_id) do
    case HTTPotion.Response.success?(response) do
        true -> :ets.insert(:responses_store, {req_id, [time: (resp_time - req_time), status_code: response.status_code] ++ response.headers})
        false -> :ets.insert(:responses_store, {req_id, [time: (resp_time - req_time), error_message: response.message]})
    end

  end

end
