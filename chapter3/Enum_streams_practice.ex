defmodule Enum_streams_practice do

  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.filter(&(String.length(&1) > 80))
  end

  def lines_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.length(&1))
  end

  def longest_line_length!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.length(&1))
    |> Enum.max()
  end

  def longest_line!(path) do
    File.stream!(path)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Enum.max_by(&String.length/1)
  end

  # def words_per_line!(path) do
  #   File.stream!(path)
  #   |> Stream.map(&String.replace(&1, "\n", ""))
  #   |> Enum.map(&1, 0)
  # end

  def words(line) do
    line
    |> String.split()
    |> length()
  end
end
