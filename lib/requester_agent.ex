defmodule  LightRequester.Requester_Agent do

  def start_link(_state, _opts \\ []) do
    Agent.start_link(fn -> %{:request_pids => [], :request_count => 0, :request_id => 0} end, name: __MODULE__)
  end

  def get_requests() do
    Agent.get(__MODULE__, &Map.get(&1, :request_pids))
  end

  def get_request_id() do
    Agent.get(__MODULE__, &Map.get(&1, :request_id))
  end

  def get_requests_count do
    Agent.get(__MODULE__, &Map.get(&1, :request_count))
  end

  def put_requests(value) do
    Agent.update(__MODULE__, &Map.put(&1, :request_pids, value))
    Agent.update(__MODULE__, &Map.put(&1, :request_count, length(value)))
  end

  def next_request_id() do
    id = get_request_id() + 1
    Agent.update(__MODULE__, &Map.put(&1, :request_id, id))
    id
  end

end
