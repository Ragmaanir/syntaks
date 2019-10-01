res = ErrorParser.new.call("var     1337").as(Error)

assert res.message == <<-MSG
Syntax error at 1:9:

1>var     1337
----------^
Rule: "var" >> space & /[a-z]+/

MSG
