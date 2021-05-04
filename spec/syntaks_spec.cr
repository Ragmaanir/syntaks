require "./spec_helper"

describe Syntaks::Parser do
  class Parser < Syntaks::Parser
    rule(root, {Token, Token, Token, Token}, id >> "=" >> value >> ";")
    rule(id, Token, /\w+/)
    rule(value, Token, /\d+/)
  end

  test "acceptance" do
    r = Parser.new.call("a=5;").as Success
    assert r.value.map(&.content) == {"a", "=", "5", ";"}

    r = Parser.new.call("number=1337;").as Success
    assert r.value.map(&.content) == {"number", "=", "1337", ";"}
  end
end

describe ActionParser do
  class Parser < Syntaks::Parser
    rule(root, {String, Int32}, id >> "=" >> value) do |v|
      {v[0], v[2]}
    end

    rule(id, String, /\w+/, &.content)
    rule(value, Int32, /\d+/, &.content.to_i)
  end

  test "AST" do
    r = Parser.new.call("var=12345").as(Success)
    assert r.value == {"var", 12345}
  end
end

describe AlternativeParser do
  abstract class Lit
  end

  class StringLit < Lit
    getter value : String

    def initialize(@value)
    end

    def ==(other : self)
      value == other.value
    end
  end

  class IntLit < Lit
    getter value : Int32

    def initialize(@value)
    end

    def ==(other : self)
      value == other.value
    end
  end

  class Parser < Syntaks::Parser
    rule(root, Lit, value | id)
    rule(id, StringLit, /\w+/) { |r| StringLit.new(r.content) }
    rule(value, IntLit, /\d+/) { |r| IntLit.new(r.content.to_i32) }
  end

  test "AST" do
    r = Parser.new.call("12345").as(Success)
    assert r.value == IntLit.new(12345)
  end
end

describe NotPredicateParser do
  class Parser < Syntaks::Parser
    rule(root, {Nil, Token}, -"x" >> "test")
  end

  test "acceptance" do
    assert Parser.new.call("xtest").is_a?(Failure)
    assert Parser.new.call("test").is_a?(Success)
  end
end

describe RegexParser do
  class Parser < Syntaks::Parser
    rule(:root, Token, identifier | literal)
    rule(:identifier, Token, /[a-z]+/)
    rule(:literal, Token, /0|([1-9][0-9]*)/)
  end

  test "acceptance" do
    assert Parser.new.call("").is_a?(Failure)
    assert Parser.new.call("\"").is_a?(Failure)
    assert Parser.new.call("%1").is_a?(Failure)
    assert Parser.new.call("0").is_a?(Success)
    assert Parser.new.call("1").is_a?(Success)
    assert Parser.new.call("100").is_a?(Success)
  end
end
