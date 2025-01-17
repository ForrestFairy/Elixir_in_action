defmodule TodogenServer do
  use GenServer

  def start do
    GenServer.start(TodogenServer, nil)
  end

  def init(_) do
    {:ok, TodoList.new}
  end

  def add_entry(todo_list, entry) do
    GenServer.cast(todo_list, {:new, entry})
  end

  def entries(todo_list, date) do
    GenServer.call(todo_list, {:entries, date})
  end


  def handle_cast({:new, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  def handle_call({:entries, date}, _, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
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
