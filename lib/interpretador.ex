defmodule Interpretador do
  alias AST
  alias InterpretadorAuxiliar

  def run(ast) do
    state = %{index: [], stack: [], output: ""}
    {final_state, _} = exec(ast, state)
    final_state.output
  end

  #avalia uma exp
  def evall(%AST{type: :constant, value: v}, state), do: {v, state}
  def evall(%AST{type: :variable, value: name}, state) do
    loc = InterpretadorAuxiliar.position(name, state.index)
    v = InterpretadorAuxiliar.fetch(loc, state.stack)
    {v, state}
  end
  def evall(%AST{type: :minus, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    {v1 - v2, state}
  end
  def evall(%AST{type: :plus, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    {v1 + v2, state}
  end
  def evall(%AST{type: :times, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    {v1 * v2, state}
  end
  def evall(%AST{type: :divide, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    if v2 == 0, do: raise("Divisão por zero"), else: {div(v1, v2), state}
  end
  def evall(%AST{type: :greater, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    if v1 > v2, do: {1, state}, else: {0, state}
  end
  def evall(%AST{type: :less, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    if v1 < v2, do: {1, state}, else: {0, state}
  end
  def evall(%AST{type: :equal, value: {e1, e2}}, state) do
    {v1, state} = evall(e1, state)
    {v2, state} = evall(e2, state)
    if v1 == v2, do: {1, state}, else: {0, state}
  end

  #executa um comando
  def exec(%AST{type: :assign, value: {name, exp}}, state) do
    {v, new_state} = evall(exp, state)
    loc = InterpretadorAuxiliar.position(name, new_state.index)
    new_stack = InterpretadorAuxiliar.put(loc, v, new_state.stack)
    {%{new_state | stack: new_stack}, new_state.output}
  end
  def exec(%AST{type: :seq, value: {c1, c2}}, state) do
    {state, _} = exec(c1, state)
    exec(c2, state)
  end
  def exec(%AST{type: :cond, value: {e, c1, c2}}, state) do
    {v, state} = evall(e, state)
    if v == 1, do: exec(c1, state), else: exec(c2, state)
  end
  def exec(%AST{type: :while, value: {e, c}}, state) do
    {v, state} = evall(e, state)
    if v == 1 do
      {state, _} = exec(c, state)
      exec(%AST{type: :while, value: {e, c}}, state)
    else
      {state, state.output}
    end
  end
  def exec(%AST{type: :declare, value: {nm, e, c}}, state) do
    {v, new_state} = evall(e, state)
    new_stack = [v | new_state.stack]
    new_index = [nm | new_state.index]
    {final_state, _} = exec(c, %{new_state | stack: new_stack, index: new_index})
    {final_state, final_state.output}
  end
  def exec(%AST{type: :print, value: exp}, state) do
    {v, new_state} = evall(exp, state)
    new_output = new_state.output <> to_string(v) <> "\n"
    {%{new_state | output: new_output}, new_output}
  end
end
