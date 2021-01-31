defmodule TodoServer do

  defstruct auto_id: 1, entries: HashDict.new

  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  def add_entry(pid, entry) do
    send(pid, {:new, entry})
  end

  def entries(pid, date) do
    send(pid, {:entries, date, self()})
    receive do
      {:answer, value} ->
        value
      after 5000 ->
        {:error, :timeout}
    end
  end

  def update(pid, entry) do
    send(pid, {:update, entry})
  end

  def delete(pid, id) do
    send(pid, {:delete, id})
  end

  defp loop(todo_list) do
    new_todo = receive do
    message ->
      process_msg(todo_list, message)
    end

    loop(new_todo)
  end

  defp process_msg(todo_list, {:new, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  defp process_msg(todo_list, {:entries, date, pid}) do
    send(pid, {:answer, TodoList.entries(todo_list, date)})
    todo_list
  end
  defp process_msg(todo_list, {:update, entry}) do
    TodoList.update_entry(todo_list, entry)
  end
  defp process_msg(todo_list, {:delete, id}) do
    TodoList.delete_entry(todo_list, id)
  end
  defp process_msg(todo_list, invalid_request) do
    IO.puts "invalid request #{inspect invalid_request}"
    todo_list
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

defmodule TodoList.CsvImporter do
  def import(path) do
    path
    |> change_into_lines
    |> create_entries
    |> TodoList.new()
  end

  def change_into_lines(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  def create_entries(lines) do
    lines
    |> Stream.map(&split_into_entries/1)
    |> Stream.map(&create_entry/1)
  end

  def split_into_entries(line) do
    line
    |> String.split(",")
    |> convert_date
  end

  def convert_date([date, title]) do
    {parse_date(date), title}
  end

  def parse_date(date_string) do
    [year, month, day] =
      date_string
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)

    {year, month, day}
    end

  def create_entry({date, title}) do
    %{date: date, title: title}
  end

  defimpl Collectable, for: TodoList do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(todo_list, :halt), do: :ok
  end
end
