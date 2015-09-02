require "../../spec_helper"

module SyntaksSpec_ListParser
  include Syntaks
  include Syntaks::Parsers

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

  describe Syntaks::Parsers::ListParser do
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

      assert result.interval.to_s == "SourceInterval(0,9)"
    end
  end

end

module SyntaksSpec_SimpleListParser
  include Syntaks
  include Syntaks::Parsers

  class Inner < InnerNode
  end

  class Term < TerminalNode
    def initialize(@state, @interval)
    end

    def internal_data
      @interval.to_s
    end
  end

  def self.list_parser
    ListParser(Inner).new(
      SequenceParser(Inner).new([
        TokenParser(Term).new(/[1-9][0-9]*/),
        TokenParser(Term).new(/[+-]/)
      ])
    )
  end

  describe Syntaks::Parsers::ListParser do
    it "does not parse an empty list" do
      parser = list_parser
      source = Source.new("")
      state = ParseState.new(source)

      assert !parser.call(state).success?
    end

    it "parses a list with multiple seperated items" do
      parser = list_parser
      source = Source.new("1+25-4")
      state = ParseState.new(source)

      assert parser.call(state).success?
    end

    it "does parse a partial list" do
      parser = list_parser
      source = Source.new("123+4334+-")
      state = ParseState.new(source)

      result = parser.call(state) as ParseSuccess

      assert result.interval.to_s == "SourceInterval(0,9)"
    end
  end
end
