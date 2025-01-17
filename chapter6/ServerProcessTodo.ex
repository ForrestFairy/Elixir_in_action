defmodule TodoServer do

  defstruct auto_id: 1, entries: HashDict.new

  def start do
    ServerProcess.start(TodoServer)
  end

  def init do
    TodoList.new
  end

  def add_entry(todo_list, entry) do
    ServerProcess.cast(todo_list, {:new, entry})
  end

  def entries(todo_list, date) do
    ServerProcess.call(todo_list, {:entries, date})
  end


  def handle_cast({:new, entry}, todo_list) do
    TodoList.add_entry(todo_list, entry)
  end
  def handle_cast(invalid_request, todo_list) do
    IO.puts "invalid request in cast #{inspect invalid_request}"
    todo_list
  end

  def handle_call({:entries, date}, todo_list) do
    {TodoList.entries(todo_list, date), todo_list}
  end
  def handle_call(invalid_request, todo_list) do
    {"invalid request in call #{inspect invalid_request}", todo_list}
  end

end


defmodule TodoList do
  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      &add_entry(&2, &1)
    )
  end

  def add_entry(
    %TodoList{entries: entries, auto_id: auto_id} = todo_list,
    entry
  ) do
    entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)

    %TodoList{todo_list |
      entries: new_entries,
      auto_id: auto_id + 1
    }
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn (_) -> new_entry end)
  end

  def update_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id,
    updater_fun
    ) do
      case entries[entry_id] do
        nil -> todo_list

        old_entry ->
          old_entry_id = old_entry.id
          new_entry = %{id: ^old_entry_id} = updater_fun.(old_entry)
          new_entries = HashDict.put(entries, new_entry.id, new_entry)
          %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(
    %TodoList{} = todo_list,
    entry_id
  ) do
    new_entries = HashDict.delete(todo_list.entries, entry_id)
    %TodoList{todo_list | entries: new_entries}
  end
end

defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} =
          callback_module.handle_call(
            request,
            current_state
          )

        send(caller, {:response, response})
        loop(callback_module, new_state)

      {:cast, request} ->
        new_state =
          callback_module.handle_cast(
            request,
            current_state
          )

        loop(callback_module, new_state)
    end
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})

    receive do
      {:response, response} ->
        response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end
end
