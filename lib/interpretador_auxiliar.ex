defmodule InterpretadorAuxiliar do
  alias AST

  # Avalia as expressões (evall)
  def evall(%AST{type: :plus, value: {left, right}}, stack), do: evall(left, stack) + evall(right, stack)
  def evall(%AST{type: :minus, value: {left, right}}, stack), do: evall(left, stack) - evall(right, stack)
  def evall(%AST{type: :times, value: {left, right}}, stack), do: evall(left, stack) * evall(right, stack)
  def evall(%AST{type: :divide, value: {left, right}}, stack), do: evall(left, stack) / evall(right, stack)
  def evall(%AST{type: :constant, value: value}, _stack), do: value
  def evall(%AST{type: :variable, value: name}, stack) do
    Map.get(stack, name, {:error, "Variável não encontrada: #{name}"})
  end

  # Executa os comandos (exec)
  def exec(%AST{type: :assign, value: {name, exp}}, stack) do
    value = evall(exp, stack)
    new_stack = Map.put(stack, name, value)
    {:ok, nil, new_stack}
  end

  def exec(%AST{type: :print, value: exp}, stack) do
    value = evall(exp, stack)
    IO.puts(value)
    {:ok, value, stack}
  end

  def exec(%AST{type: :seq, value: {head, tail}}, stack) do
    {:ok, _, new_stack} = exec(head, stack)
    if tail do
      exec(tail, new_stack)
    else
      {:ok, nil, new_stack}
    end
  end
end
