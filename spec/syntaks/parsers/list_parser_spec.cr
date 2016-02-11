require "../../spec_helper"

module ListParserTests
  class AcceptanceTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root ||= ListParser({Token, Int32}).new(
          SequenceParser.new(
            TokenParser.build(/[+-]/),
            TokenParser.build(/[1-9][0-9]*/, ->(token : Token){ token.content.to_i })
          )
        )
      end
    end

    def test_full_match
      assert TestParser.new.call("+1337").full_match?
      assert TestParser.new.call("-1+2+3+1001").full_match?
    end

    def test_partial_match
      assert TestParser.new.call("+1337+").partial_match?
      assert TestParser.new.call("-1+2+3+1001 1").partial_match?
    end

    def test_no_match
      assert !TestParser.new.call("").success?
      assert !TestParser.new.call("1337").success?
      assert !TestParser.new.call("yes").success?
    end

    def test_result
      res = TestParser.new.call("+1337") as ParseSuccess
      assert res.value.first[1] == 1337
    end
  end
end
