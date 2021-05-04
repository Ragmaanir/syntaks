require "../spec_helper"

describe Syntaks::EBNF::Rep do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, {Array(Token), Token}, {"a"} >> "b")
  end

  test "simple repetition" do
    parser = Parser.new
    assert parser.call("aaab").is_a?(Success)
    assert parser.call("b").is_a?(Success)
    assert parser.call("a").is_a?(Failure)
  end
end

describe NestedRep do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, {Array(Tuple(Token, Token)), Token}, {"a" >> "b"} >> "c")
  end

  test "nested sequence" do
    parser = Parser.new
    assert parser.call("ababc").is_a?(Success)
    assert parser.call("c").is_a?(Success)
    assert parser.call("abc").is_a?(Success)

    assert parser.call("abac").is_a?(Failure)
    assert parser.call("aaab").is_a?(Failure)
    assert parser.call("aaabc").is_a?(Failure)
    assert parser.call("ababa").is_a?(Failure)
    assert parser.call("abab").is_a?(Failure)
    assert parser.call("").is_a?(Failure)
  end
end

describe NestedRepWithoutBacktracking do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, {Array(Tuple(Token, Token)), Token}, {"a" & "b"} >> "c")
  end

  test "nested sequence" do
    parser = Parser.new
    assert parser.call("ababc").is_a?(Success)
    assert parser.call("c").is_a?(Success)
    assert parser.call("abc").is_a?(Success)

    assert parser.call("abac").is_a?(Error)
    assert parser.call("aaab").is_a?(Error)
    assert parser.call("aaabc").is_a?(Error)
    assert parser.call("ababa").is_a?(Error)

    assert parser.call("abab").is_a?(Failure)
    assert parser.call("").is_a?(Failure)
  end
end

describe RepResults do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, Array(String), {str})
    rule(:str, String, "a", &.content)
  end

  test "nested sequence" do
    parser = Parser.new
    assert_value(parser, "aaa", ["a", "a", "a"])
    assert_value(parser, "aaab", ["a", "a", "a"])
  end

  def assert_value(parser, input, value)
    res = parser.call(input)
    res = res.as(Success)
    assert res.value == value
  end
end
