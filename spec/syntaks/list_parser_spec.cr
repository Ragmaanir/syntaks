require "../spec_helper"

module ListParserSpec
  include Syntaks

  class ListNode < InnerNode
  end

  class TokenNode < TerminalNode
    def initialize(@state, @interval)
    end

    def internal_data
      @interval.to_s
    end
  end

  def self.list_parser
    ListParser(ListNode).new(
      TokenParser(TokenNode).new(/[a-z]+/),
      StringParser.new(",")
    )
  end

  describe Syntaks::ListParser do
    it "parses a list with multiple seperated items" do
      parser = list_parser
      source = Source.new("a,b,xyz")
      state = ParseState.new(source)

      assert parser.call(state).success?
    end

    it "does parse a partial list" do
      parser = list_parser
      source = Source.new("a,invalid;,xyz")
      state = ParseState.new(source)

      result = parser.call(state) as ParseSuccess

      assert result.interval.to_s == "a,invalid"
    end
  end

end
