# syntaks

A recursive descent parser generator framework.

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "ragmaanir/syntaks"
end
```

## Usage

```crystal
require "syntaks"
```

TODO: Write usage here for library

## TODO

- EBNF DSL
- selectively disable backtracking
- error-recovery productions / synchronization tokens
- optional whitespace skippers
- Simple lexer?
- Packrat parsing / memoization
- remember longest parsed prefix when parsing fails
- detailed syntax errors: display production that failed and the location where exactly it failed

## Development

TODO: Write instructions for development

## Contributing

1. Fork it ( https://github.com/ragmaanir/syntaks/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [ragmaanir](https://github.com/ragmaanir) Ragmaanir - creator, maintainer
