defmodule Parser do
  alias AST

  @spec parse(String.t()) :: {:ok, AST.t()} | {:error, String.t()}
  def parse(string) do
    # Regex para encontrar todos os números e operadores
    regex = ~r/(\d+)|([+-])/

    tokens =
      Regex.scan(regex, string, capture: :all_but_first)
      |> List.flatten
      |> Enum.reject(& &1 == nil || &1 == "")

    case tokens do
      [] ->
        {:error, "invalid expression"}

      [first | rest] ->
        term = String.to_integer(first)
        initial_ast = AST.constant(term)

        parsed_ast =
          Enum.chunk_every(rest, 2)
          |> Enum.reduce(initial_ast, fn [op, term], acc ->
            case String.to_charlist(op) |> List.first do
              ?+ -> AST.plus(acc, String.to_integer(term))
              ?- -> AST.minus(acc, String.to_integer(term))
              _ -> acc
            end
          end)

        {:ok, parsed_ast}
    end
  end
end
