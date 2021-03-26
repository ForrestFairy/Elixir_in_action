defmodule Todo.Database do
 @pool_size 3

 def start_link(db_folder) do
  IO.puts "Starting to-do database server."
  Todo.PoolSupervisor.start_link(db_folder, @pool_size)
 end

 defp get_worker(key) do
  :erlang.phash2(key, @pool_size) + 1
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

#  defp start_workers(db_folder) do
#    for index <- 1..3, into: %{} do
#     {:ok, pid} = Todo.DatabaseWorker.start_link(db_folder)
#     {index - 1, pid}
#    end
#  end
end
