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
end
