require "../spec_helper"

describe Syntaks::EBNF::Seq do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, {Token, Token, Token}, ("a" & "b") >> "c")
  end

  test "backtracking with default precedence" do
    parser = Parser.new
    assert parser.call("abc").is_a?(Success)
    assert parser.call("ab").class == Failure
    assert parser.call("a").class == Error
  end

  class Parser2 < Syntaks::Parser
    rule(:root, {Token, Token, Token}, "a" & ("b" >> "c"))
  end

  test "backtracking with compound right component" do
    parser = Parser2.new
    assert parser.call("abc").is_a?(Success)
    assert parser.call("ab").class == Error
    assert parser.call("a").class == Error
  end
end
