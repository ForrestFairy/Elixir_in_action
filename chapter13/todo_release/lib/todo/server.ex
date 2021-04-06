defmodule Todo.Server do
  use GenServer

  def start_link(name) do
    IO.puts "Starting to-do Server for #{name}."

    GenServer.start_link(Todo.Server, name, name: {:global, {:todo_server, name}})
  end

  # defp via_tuple(name) do
  #   {:via, :gproc, {:n, :l, {:todo_server, name}}}
  # end

  def whereis(name) do
    :global.whereis_name({:todo_server, name})
  end

  @impl GenServer
  def init(name) do
    {:ok, {name, Todo.Database.get(name) || Todo.List.new()}}
  end

  def add_entry(todo_list, entry) do
    GenServer.cast(todo_list, {:add_entry, entry})
  end

  def entries(todo_list, date) do
    GenServer.call(todo_list, {:entries, date})
  end

  @impl GenServer
  def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
    new_state = Todo.List.add_entry(todo_list, new_entry)
    Todo.Database.store(name, new_state)
    {:noreply, {name, new_state}}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, {name, todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
  end

end
