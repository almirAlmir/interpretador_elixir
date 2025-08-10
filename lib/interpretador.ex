defmodule Interpretador do
  alias InterpretadorAuxiliar

  def run(ast) do
    stack = %{}
    InterpretadorAuxiliar.exec(ast, stack)
  end
end
