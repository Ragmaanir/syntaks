# syntaks [![Build Status](https://travis-ci.org/Ragmaanir/syntaks.svg?branch=master)](https://travis-ci.org/Ragmaanir/syntaks)

A recursive descent parser generator framework.

## Usage

```crystal
require "syntaks"
```

TODO: Write usage here for library

## TODO

- simple token macro
- rules that do not generate ast nodes
- selectively disable backtracking
- error-recovery productions / synchronization tokens
- optional whitespace skippers
- Simple lexer?
- Packrat parsing / memoization
- remember longest parsed prefix when parsing fails
- detailed syntax errors: display production that failed and the location where exactly it failed

## DONE

- parse log
- EBNF DSL

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
