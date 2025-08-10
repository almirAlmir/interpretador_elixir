defmodule Parser do
  alias AST

  def parse(string) do
    case tokenize(string) do
      {:ok, tokens} ->
        case parse_program(tokens) do
          {:ok, ast, []} -> {:ok, ast}
          {:ok, _, _} -> {:error, "tokens invalidos restantes"}
          {:error, reason} -> {:error, reason}
        end
      {:error, _reason} -> {:error, "tokenizacao invalida"}
    end
  end

  defp tokenize(string) do
    string
    |> String.trim()
    |> String.replace("==", " == ")
    |> String.replace("=", " = ")
    |> String.replace("+", " + ")
    |> String.replace("-", " - ")
    |> String.replace("*", " * ")
    |> String.replace("/", " / ")
    |> String.replace(">", " > ")
    |> String.replace("<", " < ")
    |> String.replace("(", " ( ")
    |> String.replace(")", " ) ")
    |> String.split([" ", "\n", "\t"], trim: true)
    |> case do
      tokens when is_list(tokens) -> {:ok, tokens}
      _ -> {:error, "tokenizacao invalida"}
    end
  end

  # ---- Funções de Parsing (Recursive Descent) ----

  defp parse_program([]) do
    {:ok, nil, []}
  end

  defp parse_program(tokens) do
    case parse_command(tokens) do
      {:ok, command_ast, []} ->
        {:ok, command_ast, []}
      {:ok, command_ast, rest_tokens} ->
        {:ok, next_ast, rest_after_program} = parse_program(rest_tokens)
        {:ok, AST.seq(command_ast, next_ast), rest_after_program}
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp parse_command(tokens) do
    case tokens do
      ["print", "(", exp_token | rest_of_exp] ->
        case parse_expression([exp_token | rest_of_exp]) do
          {:ok, exp_ast, [")" | rest_after_exp]} -> {:ok, AST.print(exp_ast), rest_after_exp}
          _ -> {:error, "Falta um ')' ou entao expressao invalida no print"}
        end
      [name, "=", exp_token | rest_of_exp] ->
        case parse_expression([exp_token | rest_of_exp]) do
          {:ok, exp_ast, rest_after_exp} -> {:ok, AST.assign(name, exp_ast), rest_after_exp}
          _ -> {:error, "expressao de atribuicao invalida"}
        end
      _ ->
        {:error, "comando nao é valido"}
    end
  end

  #precedencia baixa, como comparacoes
  defp parse_expression(tokens) do
    {:ok, left, tokens_after_sum} = parse_sum(tokens)
    case tokens_after_sum do
      ["==", right_token | rest] ->
        {:ok, right, rest_after_exp} = parse_expression([right_token | rest])
        {:ok, AST.equal(left, right), rest_after_exp}
      [">", right_token | rest] ->
        {:ok, right, rest_after_exp} = parse_expression([right_token | rest])
        {:ok, AST.greater(left, right), rest_after_exp}
      ["<", right_token | rest] ->
        {:ok, right, rest_after_exp} = parse_expression([right_token | rest])
        {:ok, AST.less(left, right), rest_after_exp}
      _ ->
        {:ok, left, tokens_after_sum}
    end
  end

  #precedencia intermediaria como sub, etc
  defp parse_sum(tokens) do
    {:ok, left, tokens_after_term} = parse_term(tokens)
    case tokens_after_term do
      ["+", right_token | rest] ->
        {:ok, right, rest_after_sum} = parse_sum([right_token | rest])
        {:ok, AST.plus(left, right), rest_after_sum}
      ["-", right_token | rest] ->
        {:ok, right, rest_after_sum} = parse_sum([right_token | rest])
        {:ok, AST.minus(left, right), rest_after_sum}
      _ ->
        {:ok, left, tokens_after_term}
    end
  end

  #expressoes com a precedencia mais alta
  defp parse_term(tokens) do
    {:ok, left, tokens_after_factor} = parse_factor(tokens)
    case tokens_after_factor do
      ["*", right_token | rest] ->
        {:ok, right, rest_after_term} = parse_term([right_token | rest])
        {:ok, AST.times(left, right), rest_after_term}
      ["/", right_token | rest] ->
        {:ok, right, rest_after_term} = parse_term([right_token | rest])
        {:ok, AST.divide(left, right), rest_after_term}
      _ ->
        {:ok, left, tokens_after_factor}
    end
  end

  #numeros, vars e )
  defp parse_factor([h | t]) do
    case h do
      "(" ->
        {:ok, exp, [")" | rest]} = parse_expression(t)
        {:ok, exp, rest}
      token ->
        if String.match?(token, ~r/^\d+$/), do: {:ok, AST.constant(String.to_integer(token)), t}, else: {:ok, AST.variable(token), t}
    end
  end
end
