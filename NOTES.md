
What does not work
------------------

Need to calculate the type of a rule to annotate the instance variable that stores the rule because the instance variable is lazily initialized.

Cannot use macros in generic type parameters:

```
macro m
  Int32
end

NonTerminal(m) # expecting token 'CONST', not 'm'
```

Cannot use alias with macros:

```
macro m
  Int32
end

alias T = m # expecting token 'CONST', not 'm'
```

```
macro m
  Int32
end
alias T = typeof(m) # can't use 'typeof' here
```

```
@x : typeof(123) # cant use typeof here
```

So either this string has to be built in a macro:

```
"@xyz : T" # where T is derived by expanding a macro
```

which probably does not work, or the expression `"@xyz : T"` has to be compute by calling the run/exec macro to execute the code and get a string back.
