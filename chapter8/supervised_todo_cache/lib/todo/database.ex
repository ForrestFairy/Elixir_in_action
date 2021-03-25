defmodule Todo.Database do
 use GenServer

 def start_link(db_folder) do
  IO.puts "Starting to-do Database."

  GenServer.start_link(__MODULE__, db_folder, name: __MODULE__)
 end

 defp get_worker(key) do
  GenServer.call(__MODULE__, {:choose_worker, key})
 end

 def store(key, data) do
  key
  |> get_worker()
  |> Todo.DatabaseWorker.store(key, data)
 end

 def get(key) do
  key
  |> get_worker()
  |> Todo.DatabaseWorker.get(key)
 end

 def init(db_folder) do
  File.mkdir_p(db_folder)
  {:ok, start_workers(db_folder)}
 end

 def handle_call({:choose_worker, key}, _, workers) do
   worker_key = :erlang.phash2(key, 3)
   {:reply, Map.get(workers, worker_key), workers}
 end

 defp start_workers(db_folder) do
   for index <- 1..3, into: %{} do
    {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
    {index - 1, pid}
   end
 end
end
