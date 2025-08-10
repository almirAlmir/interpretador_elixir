defmodule AST do
  #expr
  defstruct [:type, :value]

  def constant(value),   do: %__MODULE__{type: :constant, value: value}
  def variable(name),    do: %__MODULE__{type: :variable, value: name}
  def minus(e1, e2),     do: %__MODULE__{type: :minus, value: {e1, e2}}
  def plus(e1, e2),      do: %__MODULE__{type: :plus, value: {e1, e2}}
  def times(e1, e2),     do: %__MODULE__{type: :times, value: {e1, e2}}
  def divide(e1, e2),    do: %__MODULE__{type: :divide, value: {e1, e2}}
  def greater(e1, e2),   do: %__MODULE__{type: :greater, value: {e1, e2}}
  def less(e1, e2),      do: %__MODULE__{type: :less, value: {e1, e2}}
  def equal(e1, e2),     do: %__MODULE__{type: :equal, value: {e1, e2}}

  #comandos
  def assign(name, exp), do: %__MODULE__{type: :assign, value: {name, exp}}
  def seq(c1, c2),       do: %__MODULE__{type: :seq, value: {c1, c2}}
  def cond(e, c1, c2),   do: %__MODULE__{type: :cond, value: {e, c1, c2}}
  def while(e, c),       do: %__MODULE__{type: :while, value: {e, c}}
  def declare(n, e, c),  do: %__MODULE__{type: :declare, value: {n, e, c}}
  def print(exp),        do: %__MODULE__{type: :print, value: exp}
end
