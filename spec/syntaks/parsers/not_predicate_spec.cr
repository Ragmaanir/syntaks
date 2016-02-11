require "../../spec_helper"

module NotPredicateTests
  class SimpleTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root = SequenceParser.new(
          NotPredicate.new(TokenParser.build("end")),
          TokenParser.build(/[1-9][0-9]*/, ->(token : Token){ token.content.to_i }),
        )
      end
    end

    def test_not_predicate_fail
      assert !TestParser.new.call("end").full_match?
    end

    def test_not_predicate_succeed
      assert TestParser.new.call("1337").full_match?
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::SequenceParser(Nil, Int32, {Nil, Int32})
    end
  end
end
