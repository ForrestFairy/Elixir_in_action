defmodule Simple_to_do do
  def new(), do: HashDict.new()

  def add_entry(todo, date, task) do
    HashDict.update(
      todo,
      date,
      [task],
      fn(tasks) -> [task|tasks] end
    )
  end

  def entries(todo, date) do
    HashDict.get(todo, date, [])
  end
end
