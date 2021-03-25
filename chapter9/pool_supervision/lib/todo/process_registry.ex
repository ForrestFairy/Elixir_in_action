defmodule Todo.ProcessRegistry do
  import Kernel, except: [send: 2]
  use GenServer

  def start_link do
    IO.puts "Starting process registry"
  end

  def init(_) do
    {:ok, %{}}
  end

  def register_name(key, pid) do
    GenServer.call(__MODULE__, {:register_name, key, pid})
  end

  def whereis_name(key) do
    GenServer.call(__MODULE__, {:whereis_name, key})
  end

  def send(key, msg) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, msg}}
      pid ->
        Kernel.send(pid, msg)
        pid
    end
  end

  def unregister_name({name, _}) do
    GenServer.call(__MODULE__, {:unregister_name})
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    case Map.get(process_registry, key) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(process_registry, key, pid)}
      _ ->
        {:reply, :no, process_registry}
    end
  end

  def handle_call({:whereis_name, key}, _, process_registry) do
    {
      :reply,
      Map.get(process_registry, key, :undefined),
      process_registry
    }
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    {:noreply, deregister_pid(new_registry, pid)}
  end

end
