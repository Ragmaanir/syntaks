
+ Rename call to call_impl so profiling/logging code can be injected more easily
+ BUG: parse log printing is too slow for large files -> using IO now
+ Redesign parse-log: nesting, excerpts, EBNF rule
+ Reimplement contexts and callbacks
+ `ignored`-macro that generates Nil rules
+ Create benchmark, then profile and speed up
+ Use byte-based indices to avoid slow multi-byte-based string lookups
+ Profiling context
    + self-time
    + children-time
    + self+children time
    + number of fails/success
    + count invocations of each rule

+ lint/ameba

- Better README (TODO, CHANGELOG, embedded examples like in microtest)
- Add bin/release
- Specs for parse errors/failures and incomplete parses
- Use Tokens instead of strings to delay reading from the source
- Change SourceLocation/Interval to byte indices and replace `Source#slow_lookup` invocations
- Change line/column to be zero-based in general and only add 1 for display purposes?
- Use pool/array for allocation of State, SourceLocation, SourceInterval, Token
- ProfilingContext: show max-depth
- Packrat parsing
- Print rule as EBNF string / syntaks-expression
- better error reporting/messages: "expected id /[a-z]+/, got '123'"
- Tests for all rule types
- non-terminal stack for errors
- fragments, tokens, nil-rules
