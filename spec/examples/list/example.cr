res = ListParser.new.call("(v1,v2)").as(Success)

assert res.value == ["v1", "v2"]
