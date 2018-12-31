res = ErrorParser.new.call("var x").as(Error)

assert res.message == <<-MSG
Syntax error at 1:5:

1>var x
------^
Rule: \"var \" & /[1-9][0-9]*/

MSG
