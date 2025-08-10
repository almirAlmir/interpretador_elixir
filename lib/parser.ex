defmodule Parser do
  import NimbleParsec
  alias AST

  #parser dos tokens e combinadores base
  defp ws, do: optional(whitespaces())
  defp identifier, do: utf8_char([?a-?z, ?A-?Z]) |> times(min: 1) |> optional(utf8_string([?a-?z, ?A-?Z, ?0-?9, ?_]))
  defp integer, do: integer(min: 1)
  defp reserved_word(word), do: string(word)
  defp reserved_op(op), do: string(op)
  defp wrap_paren(parser), do: ignore(string("(")) |> concat(parser) |> ignore(string(")"))

  #resolve o problema de precedencia
  defp operators do
    [
      {:infix, :left, [reserved_op("*") |> map({AST, :times, []}), reserved_op("/") |> map({AST, :divide, []})]},
      {:infix, :left, [reserved_op("+") |> map({AST, :plus, []}), reserved_op("-") |> map({AST, :minus, []})]},
      {:infix, :left, [reserved_op(">") |> map({AST, :greater, []}), reserved_op("<") |> map({AST, :less, []}), reserved_op("=") |> map({AST, :equal, []})]}
    ]
  end

  defp factor do
    choice([
      wrap_paren(rexp()),
      integer() |> map({AST, :constant, []}),
      identifier() |> map({AST, :variable, []})
    ])
  end

  defp rexp, do: expression(factor(), operators())

  #faz o parser dos comandos
  defp assign, do: identifier() |> concat(ws()) |> concat(reserved_op(":=")) |> concat(ws()) |> concat(rexp()) |> map({AST, :assign, []})

  defp seq, do: reserved_op("{") |> concat(ws()) |> concat(comP()) |> concat(reserved_op(";")) |> concat(ws()) |> concat(comP()) |> concat(ws()) |> concat(reserved_op("}")) |> map({AST, :seq, []})

  defp cond, do: reserved_word("if") |> concat(ws()) |> concat(rexp()) |> concat(ws()) |> concat(reserved_word("then")) |> concat(ws()) |> concat(comP()) |> concat(ws()) |> concat(reserved_word("else")) |> concat(ws()) |> concat(comP()) |> map({AST, :cond, []})

  defp while, do: reserved_word("while") |> concat(ws()) |> concat(rexp()) |> concat(ws()) |> concat(reserved_word("do")) |> concat(ws()) |> concat(comP()) |> map({AST, :while, []})

  defp declare, do: reserved_word("declare") |> concat(ws()) |> concat(identifier()) |> concat(ws()) |> concat(reserved_op("=")) |> concat(ws()) |> concat(rexp()) |> concat(ws()) |> concat(reserved_word("in")) |> concat(ws()) |> concat(comP()) |> map({AST, :declare, []})

  defp print, do: reserved_word("print") |> concat(ws()) |> concat(rexp()) |> map({AST, :print, []})

  defp comP, do: choice([declare(), assign(), cond(), while(), seq(), print()])

  #metodo de parsing principal
  defparsec :parse, ws() |> concat(comP()) |> concat(ws()) |> eof()
end
