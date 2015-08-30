require "../../spec_helper"

module SyntaksSpec_SequenceParser
  include Syntaks
  include Syntaks::Parsers

  class LongSentenceNode < InnerNode
  end

  class LongLongNode < InnerNode
  end

  def self.long_sentence_parser
    SequenceParser(LongSentenceNode).new([
      StringParser.new("this "),
      StringParser.new("is "),
      StringParser.new("a "),
      longlong,
      StringParser.new("sentence")
    ])
  end

  def self.longlong
    ListParser(LongLongNode).new(
      StringParser.new("long ")
    )
  end

  describe Syntaks::Parsers::SequenceParser do
    it "parses" do
      parser = long_sentence_parser
      source = Source.new("this is a long long long sentence")
      state = ParseState.new(source)

      res = parser.call(state)
      assert res.success?
    end
  end
end
