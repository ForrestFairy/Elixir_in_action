defmodule MultiDict do
  def new(), do: HashDict.new()

  def add_entry(dict, key, value) do
    HashDict.update(
      dict,
      key,
      [value],
      &[value | &1] end
    )
  end

  def get(dict, key) do
    HashDict.get(dict, key, [])
  end
end
