defmodule Calculator do
  def start() do
    spawn(fn -> loop(0) end)
  end

  def add(pid, value) do
    send(pid, {:add, value})
  end

  def sub(pid, value) do
    send(pid, {:sub, value})
  end

  def mul(pid, value) do
    send(pid, {:mul, value})
  end

  def div(pid, value) do
    send(pid, {:div, value})
  end

  def value(pid) do
    send(pid, {:value, self()})
    receive do
      {:result, value} -> value
    after 5000 ->
      {:error, :timeout}
    end

  end

  defp loop (current) do
    new_curr = receive do
      message ->
        process_message(current, message)
    end
    loop(new_curr)
  end

  defp process_message(current, {:value, caller}) do
    send(caller, {:result, current})
    current
  end
  defp process_message(current, {:add, value}), do: current + value
  defp process_message(current, {:sub, value}), do: current - value
  defp process_message(current, {:mul, value}), do: current * value
  defp process_message(current, {:div, value}), do: current / value
  defp process_message(current, invalid_request) do
    IO.puts "invalid request #{inspect invalid_request}"
    current
  end

end
