defmodule Todo.Server do
  use GenServer

  def start do
    GenServer.start(Todo.Server, nil)
  end

  @impl GenServer
  def init(_) do
    {:ok, Todo.List.new}
  end

  def add_entry(todo_list, entry) do
    GenServer.cast(todo_list, {:new, entry})
  end

  def entries(todo_list, date) do
    GenServer.call(todo_list, {:entries, date})
  end

  @impl GenServer
  def handle_cast({:new, entry}, todo_list) do
    {:noreply, Todo.List.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_call({:entries, date}, _, todo_list) do
    {:reply, Todo.List.entries(todo_list, date), todo_list}
  end

end
