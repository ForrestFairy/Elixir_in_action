defmodule Todo.ProcessRegistry do
  use GenServer
  import Kernel, except: [send: 2]

  def start_link do
    IO.puts "Starting process registry"
    GenServer.start_link(__MODULE__, nil, name: :process_registry)
  end

  def init(_) do
    :ets.new(:process_registry, [:set, :named_table, :protected])
    {:ok, nil}
  end

  def whereis_name(key) do
    case :ets.lookup(:ets_registry, key) do
      [^key, thing] -> thing
      _ -> :undefined
    end
  end

  def register_name(key, pid) do
    GenServer.call(:process_registry, {:register_name, key, pid})
  end

  def unregister_name(key) do
    GenServer.call(:process_registry, {:unregister_name, key})
  end

  def send(key, msg) do
    case whereis_name(key) do
      :undefined -> {:badarg, {key, msg}}
      pid ->
        Kernel.send(pid, msg)
        pid
    end
  end

  def handle_call({:register_name, key, pid}, _, process_registry) do
    if whereis_name(key) != :undefined do
      {:reply, :no, process_registry}

    else
      Process.monitor(pid)
      :ets.insert(:process_registry, {key, pid})
      {:reply, :yes, process_registry}
    end
  end

  def handle_call({:unregister_name, key}, _, process_registry) do
    :ets.match_delete(:process_registry, key)
    {:reply, key, process_registry}
  end

  def handle_info({:DOWN, _, :process, pid, _}, process_registry) do
    :ets.match_delete(:process_registry, {:_, pid})
    {:noreply, process_registry}
  end

  def handle_info(_, state), do: {:noreply, state}

end
