defmodule Todo.Database do
 use GenServer
 defstruct auto_id: 0, entries: HashDict.new

 def start(db_folder) do
  GenServer.start(__MODULE__, db_folder,)
 end

 def store(key, data) do
  worker = get_worker(key)
  worker.store(key, data)
 end

 def get(key) do
  worker = get_worker(key)
  worker.get(key)
 end

 def init(db_folder) do
  File.mkdir_p(db_folder)
  Enum.reduce()
  {:ok, db_folder}
 end

 def handle_cast({:store, key, data}, db_folder) do
   file_name(db_folder, key)
   |> File.write!(:erlang.term_to_binary(data))

   {:noreply, db_folder}
 end

 def handle_call({:get, key}, _, db_folder) do
   data = case File.read(file_name(db_folder, key)) do
    {:ok, contents} -> :erlang.binary_to_term(contents)
    _ -> nil
   end

   {:reply, data, db_folder}
 end

 defp file_name(db_folder, key), do: "#{db_folder}/#{key}"

end
