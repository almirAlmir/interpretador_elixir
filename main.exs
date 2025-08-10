defmodule Main do
  alias Parser
  alias Interpreter

  def main do
    IO.puts("Digite o código a ser interpretado (termina com EOF, Ctrl+D ou Ctrl+Z):")
    code = IO.read(:all)
    case Parser.program(code) do
      {:ok, ast, _, _, _, _} ->
        output = Interpreter.run(ast)
        IO.puts(output)
      {:error, reason} ->
        IO.puts("Erro de parsing: #{inspect(reason)}")
    end
  end
end
