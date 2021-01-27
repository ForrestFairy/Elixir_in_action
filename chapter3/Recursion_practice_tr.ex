defmodule Recursion_practice_tr do

    def list_len([]), do: 0
    def list_len(list) do
        list_len(list, 0)
    end

    def list_len([], sum), do: sum

    def list_len([_ | tail], sum) do
        list_len(tail, sum + 1)
    end

    def range(from, to) when from > to do

        []
    end
    def range(from, to) do
        range(from, to, [])
    end

    def range(from, to, list) when from > to do
        Enum.reverse(list)
    end

    def range(from, to, list) do
        range(from + 1, to, [from | list])
    end

    def positive([]), do: []
    def positive(list), do: positive(list, [])

    def positive([], ans), do: Enum.reverse(ans)

    def positive([head | tail], ans) when head > 0 do
        positive(tail, [head | ans])
    end

    def positive([_ | tail], ans) do
        positive(tail, ans)
    end
end