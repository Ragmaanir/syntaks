
+ Rename call to call_impl so profiling/logging code can be injected more easily
+ BUG: parse log printing is too slow for large files -> using IO now
+ Redesign parse-log: nesting, excerpts, EBNF rule
+ Reimplement contexts and callbacks

- Profiling context
    - self-time
    - children-time
    - self+children time
    - number of fails/success
    - count invocations of each rule
    - max-depth
- Create benchmark, then profile and speed up
- Packrat parsing
- Use String/IO/StringScanner
    - If IO: figure out how to use regex in that context
- Print rule as EBNF string / syntaks-expression
- better error reporting/messages: "expected id /[a-z]+/, got '123'"
- Tests for all rule types
- non-terminal stack for errors
- fragments, tokens, nil-rules
