# Interpretador Simples em Elixir
Este projeto é um interpretador para uma linguagem de programação simples, que foi adaptado a partir de uma solução original em Haskell. O interpretador é capaz de processar uma linguagem que inclui atribuição de variáveis, operações aritméticas e comandos de impressão.

### Conceitos Fundamentais
O interpretador é construído com base em três componentes principais, uma arquitetura comum na construção de compiladores e interpretadores:

* **Parser**: Analisa a string de entrada (o código-fonte) e a converte numa estrutura de dados. A implementação em Elixir usa um parser "Recursive Descent" construído manualmente.
* **Abstract Syntax Tree (AST)**: É a estrutura de dados em forma de árvore que representa a sintaxe do código-fonte. O interpretador trabalha diretamente com esta árvore, não com a string original.
* **Interpretador**: Percorre a AST e executa as ações correspondentes, como avaliar expressões e executar comandos.

### Semelhanças com a Solução em Haskell
Apesar das diferenças entre as linguagens, a arquitetura geral do projeto é a mesma da solução em Haskell:

* **Abstração de Parser**: A lógica central é a conversão do código em uma AST. Ambas as soluções separam a análise sintática da execução.
* **AST como Intermediário**: A AST é a estrutura central que representa o programa. As definições de AST em Haskell e Elixir (defstruct) são análogas, usando nós (Node ou %AST{}) para representar comandos (Seq, Assign, Print) e expressões (Plus, Times, Variable).
* **Avaliação por Recursão**: Ambas as soluções utilizam a recursão para percorrer a AST e calcular os resultados. A lógica de evaluate_node em Elixir é o equivalente direto às funções de avaliação em Haskell, que usam a correspondência de padrões para processar cada tipo de nó da AST.

### Adaptações para o Elixir
A adaptação da solução em Haskell para o Elixir exigiu algumas mudanças importantes para se alinhar com o paradigma da linguagem:

* **Gestão de Estado**: Em Elixir, a gestão do estado é explícita. O interpretador usa um Map para simular a "pilha" de variáveis. Este Map é passado entre as funções (stack) e é imutável. A cada nova atribuição, um novo Map é retornado.
* **Correspondência de Padrões (Pattern Matching)**: Enquanto em Haskell a correspondência de padrões é a base para a maioria das funções, em Elixir ela é usada de forma similar nas funções do interpretador (evaluate_node), que definem a lógica de acordo com o type do nó da AST.
* **Parser Próprio**: A solução em Haskell provavelmente utilizou uma biblioteca de parsing combinators (como Parsec). Para o Elixir, optamos por construir um parser "Recursive Descent" manualmente, usando apenas as funcionalidades da linguagem. Isso eliminou a necessidade de dependências externas e permitiu um controle total sobre a gramática, incluindo a precedência de operadores.

## Como Executar
### Instale as dependências (caso existam):

```bash
mix deps.get
```
```bash
mix compile
```
```bash
iex -S mix
```
### Defina o código a ser executado
```elixir
code = "x = 10\nprint(x * (5 + 3))"
```
### Chame o parser para obter a AST
```elixir
{:ok, ast} = Parser.parse(code)
```
### Execute a AST com o interpretador
```elixir
Interpretador.run(ast)
```

### O resultado esperado no IEx será a impressão de 80 e uma tupla com o estado final.