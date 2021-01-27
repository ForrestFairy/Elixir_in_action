defmodule TodoList do
  def new(), do: MultiDict.new()

  #dict
  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.date, entry)
  end

  #hash maps
  def add_entry(todo_list, date, task) do
    MultiDict.update(todo_list, date, task)
  end

  def entries(todo, date) do
    MultiDit.get(todo, date)
  end
end
