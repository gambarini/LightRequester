defmodule LightRequester do
  use Application
  import Supervisor.Spec
  require Logger

  alias LightRequester.Requester_Agent
  alias LightRequester.Requester
  alias LightRequester.ResponseReceiver

  def start(_type, _args) do
    Logger.info("Starting LightRequester...")

    children = [
      worker(LightRequester.Requester_Agent, [[],[]]),
      worker(Task, [fn -> ResponseReceiver.receive_responses() end]),
      supervisor(Task.Supervisor, [[name: LightRequester.TaskSupervisor]]),
      Plug.Adapters.Cowboy.child_spec(:http, LightRequester.RequesterApiPlug, [], [port: 4000])
    ]

    Logger.info("Api on localhost:4000")
    
    Supervisor.start_link(children, strategy: :one_for_one, name: LightRequester.Supervisor)

  end

  defp spawn_requester() do
    {:ok, pid} = Task.Supervisor.start_child(LightRequester.TaskSupervisor, fn -> Requester.request_action() end)
    pid
  end

  def spawn_requesters(number) do
    newRequesters = 1..number |> Stream.map(fn(_) -> spawn_requester() end) |> Enum.to_list()
    savedRequesters = Requester_Agent.get_requests()
    Requester_Agent.put_requests(savedRequesters ++ newRequesters)
  end

  def run_requesters do
    req_id = Requester_Agent.next_request_id()
    Requester_Agent.get_requests() |> Stream.map(fn(pid) -> send(pid, {:request, "https://employee-168910.appspot.com/api/employee", req_id}) end) |> Stream.run()
    :ok
  end

  def exit_requesters do
    Requester_Agent.get_requests() |> Stream.each(fn(pid) -> send(pid, {:exit}) end) |> Stream.run()
    Requester_Agent.put_requests([])
    :ok
  end

  def count_requesters do
      Requester_Agent.get_requests_count()
  end
end
