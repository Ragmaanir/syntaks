# syntaks [![Crystal CI](https://github.com/Ragmaanir/syntaks/actions/workflows/crystal.yml/badge.svg)](https://github.com/Ragmaanir/syntaks/actions/workflows/crystal.yml)

### Version 0.3.2

A parser combinator framework.

## Usage

```crystal
require "syntaks"
```

## Example

```crystal
class ListParser < Syntaks::Parser
  rule(:root, Array(String), _os >> "(" >> _os & item_list & ")") { |v| v[3] }
  rule(:item_list, Array(String), item >> ~item_list_tail) do |v|
    if tail = v[1]
      [v[0]] + tail
    else
      [v[0]]
    end
  end

  rule(:item_list_tail, Array(String), {"," & _os & item >> _os}) do |list|
    list.map(&.[2])
  end

  rule(:item, String, id >> _os) do |t|
    t[0]
  end

  rule(:id, String, /[_a-z][_a-z0-9]*/, &.content)

  ignored(:_os, /\s*/)
end


res = ListParser.new.call("(v1,v2)").as(Success)

assert res.value == ["v1", "v2"]

```

## Usage

Rules are specified in a format similar to EBNF:

```crystal
# literals/tokens
ignored(:space, /\s+/) # generates nil as AST-node
rule(:int, String, /[1-9][0-9]*/) { |m| m.content } # generates String as AST-node

# sequence
rule(:root, String, "var " >> id) { |m| m[1] } # use the second match (id) as AST-node

# sequence with backtracking disabled
rule(:root, String, "var " & id) { |m| m[1] }

# alternatives
rule(:root, String, a | b)

# repetition
rule(:root, Array(Int32), {"," >> int}) { |m| m.map(&.[1]) }
```

When backtracking is disabled an parsing fails, a syntax error is produced:

```crystal
class ErrorParser < Syntaks::Parser
  rule(:root, String, "var" >> space & /[a-z]+/) { |m| m[2].content }
  ignored(:space, /\s+/)
end


res = ErrorParser.new.call("var     1337").as(Error)

assert res.message == <<-MSG
Syntax error at 1:9:

1>var     1337
----------^
Rule: "var" >> space & /[a-z]+/

MSG

```

A parse log can be printed to inspect the parsing process:

```crystal
source = <<-SRC
  def main
    if true
      x = 1
      ⬤
    end
  end
SRC

ctx = LoggingContext.new(ParseLog.new(Source.new(source)))
res = ExampleParsers::MethodParser.new.call(source, ctx).as(Error)

log = ctx.parse_log.to_s

# The syntax error entry marked with ⚡ should be on the line that contains ⬤
assert(/⚡[^\n]+(29-33)[^\n]+⬤/ === log)

```

## TODO

- simple token macro
- rules that do not generate ast nodes
- error-recovery productions / synchronization tokens
- optional whitespace skippers
- Simple lexer?
- Packrat parsing / memoization
- remember longest parsed prefix when parsing fails

## DONE

- Use ameba
- Generated `README.md` with examples
- LoggingContext with a ParseLog
- ProfilingContext
- EBNF DSL
- Selectively disable backtracking
- Detailed syntax errors: display production that failed and the location where exactly it failed


## Contributing

1. Fork it ( https://github.com/ragmaanir/syntaks/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Ragmaanir](https://github.com/ragmaanir) - creator, maintainer
