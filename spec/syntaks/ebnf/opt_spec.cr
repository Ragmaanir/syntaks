require "../../spec_helper"

describe Syntaks::EBNF::Opt do
  include Syntaks::EBNF

  class Parser < Syntaks::Parser
    rule(:root, {Token?, Token}, ~"a" >> "c")
  end

  test "standard behavior" do
    parser = Parser.new

    assert parser.call("ac").is_a?(Success)
    assert parser.call("c").is_a?(Success)
    assert parser.call("ab").class == Failure
    assert parser.call("aac").class == Failure
  end
end
