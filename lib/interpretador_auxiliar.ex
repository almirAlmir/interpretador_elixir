defmodule InterpretadorAuxiliar do
  def position(name, index) do
    do_position(name, index, 0)
  end

  defp do_position(name, [h | _], n) when h == name, do: n
  defp do_position(name, [_ | t], n), do: do_position(name, t, n + 1)
  defp do_position(name, [], _), do: raise("Variável não encontrada: #{name}")

  def fetch(loc, stack) do
    Enum.at(stack, loc)
  end

  def put(loc, new_val, stack) do
    List.replace_at(stack, loc, new_val)
  end
end
