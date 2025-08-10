defmodule InterpretadorElixirTest do
  use ExUnit.Case
  doctest InterpretadorElixir

  test "greets the world" do
    assert InterpretadorElixir.hello() == :world
  end
end
