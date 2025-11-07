# Plano de MVP: Conversor Eficiente de Templates Ruby

## Visão Geral

Um conversor **direto e eficiente** entre ERB, Slim, HAML e Phlex, eliminando conversões intermediárias e reduzindo drasticamente o tempo de processamento através de transformações AST-para-AST.

## 1. Arquitetura Técnica

### 1.1 Abordagem: Hub-and-Spoke Modificado

**Arquitetura escolhida**: Sistema com Representação Intermediária (IR) mínima + conversões diretas otimizadas

```
┌─────────┐
│   ERB   │──┐
└─────────┘  │
             ├──→ [Parser] ──→ [IR Mínima] ──→ [Generator] ──→ ┌──────────┐
┌─────────┐  │                                                  │ Formato  │
│  HAML   │──┤                                                  │  Alvo    │
└─────────┘  │                                                  └──────────┘
             │
┌─────────┐  │
│  Slim   │──┤
└─────────┘  │
             │
┌─────────┐  │
│ Phlex   │──┘
└─────────┘

      ↓ OTIMIZAÇÃO FUTURA ↓

[Conversões Diretas para pares mais usados]
    ERB ←──────────────→ Slim
   HAML ←──────────────→ Slim
```

**Por que essa arquitetura?**
- **Eficiência**: Com N formatos, requer apenas 2N conversores (ao invés de N×(N-1))
- **Manutenibilidade**: Uma única fonte de verdade para semântica
- **Extensibilidade**: Novos formatos requerem apenas 2 conversores (parser + generator)
- **Performance**: IR mínima reduz overhead, com possibilidade de shortcuts diretos

### 1.2 Componentes Principais

**Pipeline de Conversão:**
```
Código Fonte → Parser Específico → AST Nativo → Transformador → IR Unificada
                                                                        ↓
Código Alvo ← Generator Específico ← Transformador ← IR Unificada ←────┘
```

**Três Camadas:**

1. **Camada de Parsing**: Adaptadores específicos para cada formato
2. **Camada Intermediária (IR)**: Representação unificada de conceitos de template
3. **Camada de Geração**: Geradores específicos para cada formato

## 2. Estrutura do Código

### 2.1 Organização de Diretórios

```
template_converter/
├── lib/
│   ├── template_converter.rb           # Entry point principal
│   ├── template_converter/
│   │   ├── version.rb
│   │   ├── cli.rb                      # Interface linha de comando
│   │   │
│   │   ├── ir/                         # Representação Intermediária
│   │   │   ├── node.rb                 # Classe base para nós
│   │   │   ├── template.rb             # Documento raiz
│   │   │   ├── element.rb              # Elementos HTML
│   │   │   ├── expression.rb           # Expressões Ruby
│   │   │   ├── block.rb                # Blocos de código
│   │   │   ├── conditional.rb          # if/elsif/else
│   │   │   ├── loop.rb                 # each/while/for
│   │   │   ├── static_content.rb       # Texto estático
│   │   │   └── visitor.rb              # Pattern visitor
│   │   │
│   │   ├── parsers/                    # Parsers específicos → IR
│   │   │   ├── base_parser.rb
│   │   │   ├── erb_parser.rb           # ERB → IR
│   │   │   ├── haml_parser.rb          # HAML → IR
│   │   │   ├── slim_parser.rb          # Slim → IR
│   │   │   └── phlex_parser.rb         # Phlex → IR
│   │   │
│   │   ├── generators/                 # Generators IR → formato
│   │   │   ├── base_generator.rb
│   │   │   ├── erb_generator.rb        # IR → ERB
│   │   │   ├── haml_generator.rb       # IR → HAML
│   │   │   ├── slim_generator.rb       # IR → Slim
│   │   │   └── phlex_generator.rb      # IR → Phlex
│   │   │
│   │   ├── transformers/               # Transformações e otimizações
│   │   │   ├── normalizer.rb          # Normalização de IR
│   │   │   ├── optimizer.rb           # Otimizações (combinar nós estáticos)
│   │   │   └── validator.rb           # Validação de IR
│   │   │
│   │   └── errors.rb                   # Classes de erro customizadas
│   │
├── test/                               # Testes com Minitest
│   ├── test_helper.rb
│   ├── fixtures/                       # Templates de exemplo
│   │   ├── erb/
│   │   ├── haml/
│   │   ├── slim/
│   │   └── phlex/
│   ├── parsers/
│   ├── generators/
│   ├── ir/
│   └── integration/
│       └── roundtrip_test.rb           # Testes roundtrip críticos
│
├── benchmarks/                         # Performance benchmarks
│   └── conversion_benchmark.rb
│
├── bin/
│   └── template_converter              # Executável CLI
│
├── Gemfile
├── Rakefile                            # Tasks: test, benchmark, etc.
├── template_converter.gemspec
└── README.md
```

### 2.2 Representação Intermediária (IR)

**Estrutura de Nós:**

```ruby
module Any2Any
  module IR
    # Nó base com visitor pattern
    class Node
      attr_reader :source_location

      def initialize(source_location: nil)
        @source_location = source_location
      end

      def accept(visitor)
        visitor.visit(self)
      end
    end

    # Template raiz
    class Template < Node
      attr_reader :children

      def initialize(children: [], **opts)
        super(**opts)
        @children = children
      end
    end

    # Elemento HTML
    class Element < Node
      attr_reader :tag_name, :attributes, :children, :self_closing

      def initialize(tag_name:, attributes: {}, children: [],
                     self_closing: false, **opts)
        super(**opts)
        @tag_name = tag_name
        @attributes = attributes
        @children = children
        @self_closing = self_closing
      end
    end

    # Expressão Ruby (com output)
    class Expression < Node
      attr_reader :code, :escaped

      def initialize(code:, escaped: true, **opts)
        super(**opts)
        @code = code
        @escaped = escaped
      end
    end

    # Bloco de código Ruby (sem output)
    class Block < Node
      attr_reader :code, :children

      def initialize(code:, children: [], **opts)
        super(**opts)
        @code = code
        @children = children
      end
    end

    # Condicional
    class Conditional < Node
      attr_reader :condition, :true_branch, :false_branch

      def initialize(condition:, true_branch: [], false_branch: [], **opts)
        super(**opts)
        @condition = condition
        @true_branch = true_branch
        @false_branch = false_branch
      end
    end

    # Loop
    class Loop < Node
      attr_reader :collection, :variable, :body

      def initialize(collection:, variable:, body: [], **opts)
        super(**opts)
        @collection = collection
        @variable = variable
        @body = body
      end
    end

    # Conteúdo estático
    class StaticContent < Node
      attr_reader :text

      def initialize(text:, **opts)
        super(**opts)
        @text = text
      end
    end

    # Comentário
    class Comment < Node
      attr_reader :text, :html_visible

      def initialize(text:, html_visible: false, **opts)
        super(**opts)
        @text = text
        @html_visible = html_visible
      end
    end
  end
end
```

### 2.3 Interface Principal

```ruby
module Any2Any
  class Converter
    # Conversão simples
    def self.convert(source, from:, to:, options: {})
      new(options).convert(source, from: from, to: to)
    end

    def initialize(options = {})
      @options = default_options.merge(options)
    end

    def convert(source, from:, to:)
      # 1. Parse source para IR
      parser = parser_for(from)
      ir = parser.parse(source)

      # 2. Transformações opcionais
      ir = transform(ir) if @options[:optimize]

      # 3. Validação
      validate(ir) if @options[:validate]

      # 4. Gerar formato target
      generator = generator_for(to)
      generator.generate(ir)
    rescue => e
      handle_error(e, source, from, to)
    end

    private

    def parser_for(format)
      case format
      when :erb then Parsers::ErbParser.new(@options)
      when :haml then Parsers::HamlParser.new(@options)
      when :slim then Parsers::SlimParser.new(@options)
      when :phlex then Parsers::PhlexParser.new(@options)
      else raise UnsupportedFormat, "Format #{format} not supported"
      end
    end

    def generator_for(format)
      case format
      when :erb then Generators::ErbGenerator.new(@options)
      when :haml then Generators::HamlGenerator.new(@options)
      when :slim then Generators::SlimGenerator.new(@options)
      when :phlex then Generators::PhlexGenerator.new(@options)
      else raise UnsupportedFormat, "Format #{format} not supported"
      end
    end

    def transform(ir)
      ir = Transformers::Normalizer.new.transform(ir)
      ir = Transformers::Optimizer.new.transform(ir) if @options[:optimize]
      ir
    end

    def validate(ir)
      Transformers::Validator.new.validate!(ir)
    end
  end
end
```

## 3. Funcionalidades do MVP

### 3.1 Prioridades (Fase 1 - "Fazer Funcionar")

**Objetivo**: Conversões básicas funcionando 100% para casos comuns

**Conversões Prioritárias:**
1. **ERB ↔ Slim** (mais demandado, gap atual significativo)
2. **HAML ↔ Slim** (conversão direta não existe hoje)
3. **ERB ↔ HAML** (melhorar ferramentas existentes)

**Funcionalidades Core:**

✅ **Tags HTML básicos**
- Elementos simples: `div`, `p`, `span`, `h1-h6`, etc.
- Atributos estáticos: `class`, `id`, outros
- Self-closing tags: `br`, `hr`, `img`, `input`
- Tags aninhados com indentação correta

✅ **Expressões Ruby**
- Output com escape: `<%= expr %>` / `= expr` / `= expr`
- Output sem escape: `<%== expr %>` / `!= expr` / `== expr`
- Interpolação: `#{expr}` dentro de strings

✅ **Blocos de código**
- Execução sem output: `<% code %>` / `- code` / `- code`
- Estruturas de controle básicas

✅ **Condicionais**
- `if/elsif/else/end`
- Ternários simples em atributos

✅ **Loops**
- `each do |var|`
- `while`/`until`
- Iteração sobre coleções

✅ **Atributos dinâmicos**
- Classes condicionais: `class: active? ? 'active' : ''`
- Interpolação em atributos: `href="/user/#{id}"`
- Arrays de classes (HAML/Slim): `class: ['base', 'extra']`

✅ **Comentários**
- Comentários de código (não aparecem em HTML)
- Comentários HTML (aparecem em HTML)

✅ **Conteúdo misto**
- Texto estático + expressões dinâmicas
- Múltiplos níveis de aninhamento

### 3.2 Fora do Escopo do MVP

**Deixar para depois** (Fase 2):
- ❌ Filtros especiais (`:javascript`, `:markdown`, `:ruby`)
- ✅ **Conversão para/de Phlex (paradigma muito diferente) - IMPLEMENTADO E TESTADO!**
- ❌ Helpers Rails complexos (`form_for`, `link_to` com blocos)
- ❌ Partials e layouts (paths de arquivo)
- ❌ Otimizações avançadas de performance
- ❌ Detecção inteligente de formato de entrada
- ❌ Preservação de formatação/comentários originais
- ❌ Conversões incrementais (apenas arquivos modificados)

### 3.3 Edge Cases - Tratamento Explícito

**Estratégia**: Avisos claros + degradação graciosa

**Casos especiais com warnings:**
- ⚠️ Whitespace significativo complexo → Warning + melhor esforço
- ⚠️ JavaScript/CSS inline com ERB tags → Warning + converter estrutura
- ⚠️ Atributos com hashes aninhados → Warning + simplificar
- ⚠️ Filtros não suportados → Warning + comentário no output
- ⚠️ Sintaxe Ruby muito complexa → Warning + preservar como string

**Implementação de Warnings:**
```ruby
class ConversionWarning
  attr_reader :line, :column, :severity, :message, :suggestion

  SEVERITIES = [:info, :warning, :error]

  def initialize(line:, message:, severity: :warning, suggestion: nil)
    @line = line
    @severity = severity
    @message = message
    @suggestion = suggestion
  end

  def to_s
    msg = "[#{severity.upcase}] Line #{line}: #{message}"
    msg += "\n  Suggestion: #{suggestion}" if suggestion
    msg
  end
end

# Coletor de warnings durante conversão
class WarningCollector
  def initialize
    @warnings = []
  end

  def add(warning)
    @warnings << warning
  end

  def summary
    grouped = @warnings.group_by(&:severity)
    "Conversion complete: #{grouped[:error]&.count || 0} errors, " \
    "#{grouped[:warning]&.count || 0} warnings, " \
    "#{grouped[:info]&.count || 0} info messages"
  end
end
```

## 4. Tecnologias e Bibliotecas

### 4.1 Dependências Core

**Para Parsing:**
```ruby
# Gemfile
gem 'temple', '~> 0.10'        # S-expressions para Slim/HAML
gem 'slim', '~> 5.2'           # Parser Slim (Temple S-expressions)
gem 'haml', '~> 6.0'           # Parser HAML oficial
gem 'herb', '~> 0.1'           # Parser ERB com AST (2025)
# Alternativa se Herb não estável: 'erubi' + parser customizado

# Para geração de código Ruby
gem 'parser', '~> 3.3'         # AST Ruby (para Phlex futuro)
gem 'unparser', '~> 0.6'       # Ruby code generation
```

**Para Testes:**
```ruby
# Gemfile (development/test)
group :development, :test do
  gem 'minitest', '~> 5.20'    # Já vem com Ruby, leve e rápido
  gem 'minitest-reporters'     # Output mais bonito
  gem 'simplecov'              # Coverage
  gem 'benchmark-ips'          # Performance benchmarks
  gem 'debug'                  # Debugger nativo do Ruby 3+
end
```

**Para CLI:**
```ruby
gem 'thor', '~> 1.3'           # CLI framework
gem 'tty-prompt'               # Interactive prompts
gem 'pastel'                   # Colored output
```

### 4.2 Stack Tecnológico Detalhado

**Parsing por Formato:**

| Formato | Biblioteca | Motivo | Output |
|---------|-----------|--------|--------|
| **Slim** | `slim` gem + Temple | Parser oficial, S-expressions bem documentadas | Temple Sexp |
| **HAML** | `haml_parser` gem | AST limpo e bem estruturado | AST nodes |
| **ERB** | `herb` gem | HTML-aware, AST completo (2025) | AST completo |
| **Phlex** | `parser` gem | Análise de código Ruby | Ruby AST |

**Arquitetura de Parsers:**

```ruby
module Any2Any
  module Parsers
    # Parser Slim: usa Temple S-expressions
    class SlimParser < BaseParser
      def parse(source)
        require 'slim'
        sexp = Slim::Parser.new.call(source)
        transform_sexp_to_ir(sexp)
      end

      private

      def transform_sexp_to_ir(sexp)
        case sexp[0]
        when :multi
          sexp[1..-1].map { |child| transform_sexp_to_ir(child) }
        when :html
          transform_html_sexp(sexp)
        when :static
          IR::StaticContent.new(text: sexp[1])
        when :dynamic
          IR::Expression.new(code: sexp[1], escaped: true)
        when :code
          IR::Block.new(code: sexp[1])
        # ... outros casos
        end
      end
    end

    # Parser HAML: usa haml_parser gem
    class HamlParser < BaseParser
      def parse(source)
        require 'haml_parser'
        ast = HamlParser::Ast.parse(source)
        transform_haml_ast_to_ir(ast)
      end

      private

      def transform_haml_ast_to_ir(node)
        case node
        when HamlParser::Ast::Root
          IR::Template.new(
            children: node.children.map { |c| transform_haml_ast_to_ir(c) }
          )
        when HamlParser::Ast::Element
          IR::Element.new(
            tag_name: node.tag_name,
            attributes: transform_attributes(node),
            children: transform_children(node)
          )
        # ... outros casos
        end
      end
    end

    # Parser ERB: usa Herb
    class ErbParser < BaseParser
      def parse(source)
        require 'herb'
        ast = Herb.parse(source)
        transform_herb_ast_to_ir(ast)
      end

      private

      def transform_herb_ast_to_ir(node)
        # Implementação baseada na estrutura do Herb AST
        # (documentação específica quando disponível)
      end
    end
  end
end
```

## 5. Plano de Implementação "Fazer Funcionar Primeiro"

### 5.1 Fase 1: Foundation (Semana 1-2)

**Objetivo**: Infraestrutura básica funcionando

**Tarefas:**
1. ✅ Setup do projeto (gem structure, minitest, CI)
2. ✅ Definir classes IR completas
3. ✅ Implementar Visitor pattern para IR
4. ✅ Parser Slim → IR (casos simples)
5. ✅ Generator IR → Slim (casos simples)
6. ✅ Testes unitários para IR nodes
7. ✅ Primeiro teste de integração: Slim → IR → Slim

**Critério de Sucesso:**
```ruby
# Deve funcionar:
input = "div\n  p Hello"
ir = SlimParser.new.parse(input)
output = SlimGenerator.new.generate(ir)
# output == input (ou equivalente)
```

### 5.2 Fase 2: Core Conversions (Semana 3-4)

**Objetivo**: Conversões básicas entre Slim ↔ HAML

**Tarefas:**
1. ✅ Parser HAML → IR completo
2. ✅ Generator IR → HAML completo
3. ✅ Testes roundtrip: Slim → HAML → Slim
4. ✅ Testes roundtrip: HAML → Slim → HAML
5. ✅ Suporte a atributos básicos
6. ✅ Suporte a expressões Ruby simples
7. ✅ Suporte a condicionais e loops
8. ✅ Test suite com 50+ casos reais

**Critério de Sucesso:**
- 90%+ dos templates simples convertem corretamente
- Rendering antes/depois é idêntico
- Zero crashes, apenas warnings para casos não suportados

### 5.3 Fase 3: ERB Support (Semana 5-6)

**Objetivo**: Adicionar suporte completo a ERB

**Tarefas:**
1. ✅ Parser ERB → IR
2. ✅ Generator IR → ERB
3. ✅ Testes para todas as combinações:
   - ERB ↔ Slim
   - ERB ↔ HAML
4. 🔄 Edge cases: whitespace, comentários, atributos dinâmicos
5. ✅ Test suite expandido: 100+ casos (fixtures criados)
6. ✅ Testes com templates reais (gems populares) - fixtures Rails criados

**Critério de Sucesso:**
- Conversões ERB funcionando para 85%+ dos casos comuns
- Sistema de warnings robusto
- Documentação de casos não suportados

### 5.4 Fase 4: Polish & CLI (Semana 7-8)

**Objetivo**: Produto utilizável em produção

**Tarefas:**
1. ✅ Interface CLI completa (bin/any2any exists)
2. 🔄 Batch conversion (diretórios inteiros) - CLI precisa implementação completa
3. 🔄 Sistema de warnings e relatórios - parcialmente implementado
4. ✅ Validação de output
5. 🔄 Documentação completa - README atualizado, falta CLI docs
6. ❌ Performance benchmarks - não implementado
7. ❌ Gem publicada no RubyGems - pronto para publicação local

**CLI Interface:**
```bash
# Conversão individual
template_converter convert input.slim --from slim --to haml --output output.haml

# Conversão em lote
template_converter batch app/views --from erb --to slim --recursive

# Preview/dry-run
template_converter convert input.erb --to slim --dry-run --diff

# Com opções
template_converter convert input.haml --to slim \
  --validate \
  --optimize \
  --warnings-as-errors
```

**Relatório de Conversão:**
```
Converting: app/views/users/_form.html.erb → app/views/users/_form.html.slim

[INFO] Line 15: Using simplified attribute syntax
[WARNING] Line 42: Complex JavaScript block may need manual review
[INFO] Line 67: Converted helper method to Slim syntax

Conversion complete: 0 errors, 1 warning, 2 info messages
Output written to: app/views/users/_form.html.slim
Original backed up to: app/views/users/_form.html.erb.bak

Batch Summary:
✓ 45 files converted successfully
⚠ 5 files with warnings (need review)
✗ 0 files failed
```

## 6. Estratégia de Testes com Minitest

### 6.1 Pirâmide de Testes

```
              /\
             /  \     E2E: Full conversions (10%)
            /    \
           /------\   Integration: Parser→IR→Generator (30%)
          /        \
         /----------\ Unit: Individual components (60%)
```

**Unit Tests (60%):**
- Cada tipo de IR Node
- Cada método de Parser
- Cada método de Generator
- Transformadores e validators

**Integration Tests (30%):**
- Parser completo → IR
- IR → Generator completo
- Parser → IR → Generator (pipeline)
- Edge cases específicos

**E2E Tests (10%):**
- Roundtrip testing: A → B → A
- Templates reais de gems populares
- Comparação de rendering

### 6.2 Estrutura de Testes Minitest

```ruby
# test/test_helper.rb
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

require 'template_converter'

# test/ir/test_element.rb
require 'test_helper'

class TestElement < Minitest::Test
  def test_creates_element_with_tag_name
    element = Any2Any::IR::Element.new(tag_name: 'div')
    assert_equal 'div', element.tag_name
  end

  def test_creates_self_closing_element
    element = Any2Any::IR::Element.new(
      tag_name: 'br',
      self_closing: true
    )
    assert element.self_closing
  end
end

# test/parsers/test_slim_parser.rb
require 'test_helper'

class TestSlimParser < Minitest::Test
  def setup
    @parser = Any2Any::Parsers::SlimParser.new
  end

  def test_parses_simple_div
    source = "div"
    ir = @parser.parse(source)

    assert_instance_of Any2Any::IR::Template, ir
    assert_equal 1, ir.children.length

    element = ir.children.first
    assert_instance_of Any2Any::IR::Element, element
    assert_equal 'div', element.tag_name
  end

  def test_parses_nested_elements
    source = "div\n  p Hello"
    ir = @parser.parse(source)

    div = ir.children.first
    assert_equal 1, div.children.length

    p_tag = div.children.first
    assert_equal 'p', p_tag.tag_name
  end
end
```

### 6.3 Roundtrip Testing (CRÍTICO)

```ruby
# test/integration/test_roundtrip.rb
require 'test_helper'

class TestRoundtrip < Minitest::Test
  FIXTURES_DIR = File.expand_path('../fixtures', __dir__)

  # Testa cada fixture em roundtrip
  Dir["#{FIXTURES_DIR}/**/*.{erb,haml,slim}"].each do |fixture_path|
    original_format = File.extname(fixture_path)[1..-1].to_sym
    fixture_name = File.basename(fixture_path)

    [:erb, :haml, :slim].each do |target_format|
      next if original_format == target_format

      define_method "test_roundtrip_#{fixture_name}_to_#{target_format}" do
        original = File.read(fixture_path)

        # Original → Target
        converted = Any2Any.convert(
          original,
          from: original_format,
          to: target_format
        )

        # Target → Original
        back = Any2Any.convert(
          converted,
          from: target_format,
          to: original_format
        )

        # Compare rendered output (não sintaxe)
        assert_equal render(original), render(back),
          "Roundtrip failed for #{fixture_name}"
      end
    end
  end

  private

  def render(template)
    # Helper para renderizar template e comparar HTML
    # Implementação depende do formato
  end
end
```

### 6.4 Property-Based Testing

```ruby
# test/integration/test_properties.rb
require 'test_helper'

class TestProperties < Minitest::Test
  def test_never_crashes_on_valid_slim
    100.times do
      template = generate_random_valid_slim

      assert_nothing_raised do
        Any2Any.convert(template, from: :slim, to: :haml)
      end
    end
  end

  def test_preserves_tag_count
    template = generate_template_with_known_tags(10)
    converted = Any2Any.convert(template, from: :slim, to: :haml)

    assert_equal 10, count_tags(converted)
  end

  def test_preserves_ruby_code_in_expressions
    ruby_code = "@user.name.upcase"
    slim = "p = #{ruby_code}"
    haml = Any2Any.convert(slim, from: :slim, to: :haml)

    assert_includes haml, ruby_code
  end

  private

  def generate_random_valid_slim
    # Gera template Slim válido aleatório
    tags = %w[div p span h1 h2 ul li]
    tag = tags.sample
    "#{tag}\n  | Text content"
  end

  def generate_template_with_known_tags(count)
    count.times.map { "div" }.join("\n")
  end

  def count_tags(template)
    # Conta número de tags no template
    template.scan(/<\w+/).length
  end
end
```

### 6.5 Rakefile para Testes

```ruby
# Rakefile
require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# Testes específicos
namespace :test do
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/{ir,parsers,generators}/**/*_test.rb']
  end

  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/integration/**/*_test.rb']
  end
end

# Benchmarks
task :benchmark do
  ruby 'benchmarks/conversion_benchmark.rb'
end

task default: :test
```

**Comandos:**
```bash
# Rodar todos os testes
rake test

# Apenas unit tests
rake test:unit

# Apenas integration tests
rake test:integration

# Com coverage
COVERAGE=true rake test

# Benchmarks
rake benchmark
```

### 6.6 Performance Testing

```ruby
# benchmarks/conversion_benchmark.rb
require 'benchmark/ips'
require 'template_converter'

# Carregar fixtures
small_erb = File.read('test/fixtures/erb/small.erb')
medium_haml = File.read('test/fixtures/haml/medium.haml')
large_slim = File.read('test/fixtures/slim/large.slim')

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  # Small template (< 50 lines)
  x.report("small ERB → Slim") do
    Any2Any.convert(small_erb, from: :erb, to: :slim)
  end

  # Medium template (100-500 lines)
  x.report("medium HAML → Slim") do
    Any2Any.convert(medium_haml, from: :haml, to: :slim)
  end

  # Large template (> 500 lines)
  x.report("large Slim → ERB") do
    Any2Any.convert(large_slim, from: :slim, to: :erb)
  end

  x.compare!
end

# Target: Small < 50ms, Medium < 500ms, Large < 2s
```

## 7. Performance e Otimizações

### 7.1 Otimizações de Performance (Fase 2+)

**Depois do MVP funcionar, focar em:**

1. **Cache de Parsers:**
```ruby
class ParserCache
  def initialize
    @cache = {}
  end

  def get_parser(format)
    @cache[format] ||= create_parser(format)
  end
end
```

2. **Lazy Evaluation:**
```ruby
# Não parse tudo se só precisa de metadados
class Parser
  def parse_metadata(source)
    # Parse apenas cabeçalho/estrutura básica
  end

  def parse_full(source)
    # Parse completo apenas quando necessário
  end
end
```

3. **String Building Eficiente:**
```ruby
# Usar String#<< ao invés de +
def generate_output
  output = String.new
  nodes.each do |node|
    output << generate_node(node)  # Rápido
    # NÃO: output = output + generate_node(node)  # Lento
  end
  output
end
```

4. **Regex Precompilado:**
```ruby
class Parser
  TAG_PATTERN = /\A(\w+)/.freeze
  ATTR_PATTERN = /\A\s*(\w+)=/.freeze

  def parse_tag(line)
    line.match(TAG_PATTERN)  # Rápido (regex frozen)
  end
end
```

5. **Pool de Objetos IR:**
```ruby
# Para conversões em lote, reusar objetos IR
class IRPool
  def initialize
    @pool = Hash.new { |h, k| h[k] = [] }
  end

  def acquire(klass)
    @pool[klass].pop || klass.new
  end

  def release(obj)
    obj.reset!
    @pool[obj.class] << obj
  end
end
```

### 7.2 Benchmarks de Referência

**Targets para MVP:**
- Small files (< 100 lines): < 100ms
- Medium files (100-500 lines): < 500ms
- Large files (> 500 lines): < 2s
- Batch (100 files): < 30s

**Comparação com ferramentas existentes:**
```
Conversão ERB → Slim (100 linhas):
- Atual (html2haml + haml2slim): ~2-3s (múltiplos passos)
- MVP target: < 200ms (conversão direta)
- Speedup esperado: 10-15x
```

## 8. Próximas Etapas Após MVP

### 8.1 Fase 2: Enhancement (Pós-MVP)

**Funcionalidades Adicionais:**
1. ✨ Suporte a Phlex (conversão de/para)
2. ✨ Filtros especiais (`:javascript`, `:markdown`)
3. ✨ Helpers Rails complexos
4. ✨ Preservação de comentários e formatação
5. ✨ Auto-detecção de formato
6. ✨ Conversão incremental (apenas arquivos modificados)
7. ✨ Plugin system para extensões customizadas

### 8.2 Fase 3: Polish (Maturidade)

**Melhorias de Qualidade:**
1. 🎯 Otimizações avançadas de performance
2. 🎯 Suporte a mais formatos (Liquid, Mustache)
3. 🎯 Integração com ferramentas de build (Rails generators)
4. 🎯 Language Server Protocol (LSP) para editors
5. 🎯 Web interface para conversão online
6. 🎯 Comprehensive documentation site
7. 🎯 Screencasts e tutoriais

### 8.3 Roadmap Visual

```
MVP (v0.1.0) ─────────── Enhancement (v0.5.0) ─────────── Polish (v1.0.0)
    │                           │                              │
    ├─ ERB ↔ Slim              ├─ Phlex support               ├─ LSP integration
    ├─ HAML ↔ Slim             ├─ Filters                     ├─ Web interface
    ├─ ERB ↔ HAML              ├─ Rails helpers               ├─ More formats
    ├─ CLI básico              ├─ Format detection            ├─ Documentation site
    ├─ Warnings                ├─ Incremental conversion      └─ Tutorials
    └─ 85% accuracy            └─ Plugin system

  [8 semanas]                [4-6 semanas]                  [Ongoing]
```

## 9. Riscos e Mitigações

### 9.1 Riscos Técnicos

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| **Herb gem instável** | Média | Alto | Fallback para Erubi + custom parser |
| **Edge cases inesperados** | Alta | Médio | Sistema robusto de warnings + testes extensivos |
| **Performance ruim** | Baixa | Médio | Benchmarks desde início + otimizações pós-MVP |
| **Temple API muda** | Baixa | Alto | Pin version específica, testes extensivos |
| **Incompatibilidade Ruby 3.x** | Baixa | Médio | CI com múltiplas versões Ruby |

### 9.2 Riscos de Projeto

| Risco | Probabilidade | Impacto | Mitigação |
|-------|--------------|---------|-----------|
| **Scope creep** | Alta | Alto | **Foco absoluto no MVP: "fazer funcionar primeiro"** |
| **Falta de casos de teste reais** | Média | Médio | Coletar templates de gems populares (Devise, ActiveAdmin) |
| **User adoption baixa** | Média | Alto | Marketing: blog posts, demos, integração Rails |
| **Manutenção longa** | Média | Médio | Código limpo, documentado, testes 90%+ |

## 10. Métricas de Sucesso

### 10.1 Métricas Técnicas

**MVP considerado sucesso se:**
- ✅ **85%+ accuracy** em templates comuns (test suite)
- ✅ **10x faster** que conversões multi-step existentes
- ✅ **Zero crashes** em templates válidos (warnings ok)
- ✅ **90%+ test coverage**
- ✅ **Roundtrip tests** passando para casos básicos
- ✅ **CLI funcional** com batch conversion

### 10.2 Métricas de Adoção

**Sucesso de adoção se:**
- 🎯 100+ downloads no RubyGems no primeiro mês
- 🎯 50+ stars no GitHub
- 🎯 5+ issues/PRs da comunidade
- 🎯 Mencionado em pelo menos 2 blogs/podcasts Ruby
- 🎯 Usado em pelo menos 1 projeto production (além do autor)

## 11. Conclusão: Princípios do MVP

**"Fazer Funcionar 100% Primeiro, Refatorar Depois"**

### Foco Absoluto:
1. ✅ **Funcionalidade sobre elegância** - código funcional > código bonito
2. ✅ **Casos comuns sobre edge cases** - 80% dos casos primeiro
3. ✅ **Testes sobre features** - cada feature tem testes antes de próxima
4. ✅ **Warnings sobre perfeição** - avisar sobre problemas, não bloquear
5. ✅ **Iteração sobre planejamento** - lançar rápido, melhorar sempre

### O Que NÃO Fazer no MVP:
- ❌ Otimizações prematuras
- ❌ Abstração excessiva
- ❌ Features "nice to have"
- ❌ Suporte a 100% dos edge cases
- ❌ Performance perfeita
- ❌ UI/UX polida

### O Que SIM Fazer:
- ✅ Testes robustos desde o dia 1
- ✅ Documentação básica mas clara
- ✅ Erros claros e úteis
- ✅ Lançar em 8 semanas máximo
- ✅ Coletar feedback cedo

---

## 12. Quick Start para Desenvolvimento

```bash
# Setup inicial
git clone https://github.com/seu-usuario/template_converter
cd template_converter
bundle install

# Rodar testes
rake test

# Rodar testes específicos
rake test:unit
rake test:integration

# Benchmarks
rake benchmark

# Usar CLI
bundle exec bin/template_converter convert input.erb --to slim

# Desenvolvimento iterativo com Minitest
# 1. Escrever teste que falha
# 2. Implementar feature mínima
# 3. Fazer teste passar
# 4. Refatorar se necessário
# 5. Commit
# 6. Próxima feature
```

**Pronto para começar a implementar!** 🚀

Este plano oferece uma arquitetura clara, pragmática e focada em resultados. O objetivo é ter um conversor funcional em 8 semanas que resolve 85% dos casos comuns de forma muito mais eficiente que as soluções atuais.
