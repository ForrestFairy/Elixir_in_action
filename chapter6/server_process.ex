defmodule ServerProcess do
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(
          request,
          current_state
        )

        send(caller, {:response, response})

        loop(callback_module, new_state)
    end

  end

  def call(server_pid, request) do
    send(server_pid, {request, self()})

    receive do
      {:response, response} ->
        response
    end
  end
end

defmodule KeyValueStore do
  def init do
    HashDict.new
  end

  def handle_call({:put, key, value}, state) do
    {:ok, HashDict.put(state, key, value)}
  end
  def handle_call({:get, key}, state) do
    {HashDict.get(state, key), state}
  end
end
