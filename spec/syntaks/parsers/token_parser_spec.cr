require "../../spec_helper"

module TokenParserTests
  class SimpleTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root = TokenParser.build(/[1-9][0-9]*/, ->(token : Token){ token.content.to_i })
      end
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::TokenParser(Int32)
    end

    def test_full_match
      assert TestParser.new.call("1337").full_match?
      assert TestParser.new.call("1").full_match?
    end

    def test_partial_match
      assert TestParser.new.call("1337test").partial_match?
    end

    def test_no_match
      assert !TestParser.new.call("").success?
      assert !TestParser.new.call("001337").success?
      assert !TestParser.new.call("---asd").success?
    end

    def test_result
      res = TestParser.new.call("250") as ParseSuccess
      assert res.value == 250
    end
  end
end
