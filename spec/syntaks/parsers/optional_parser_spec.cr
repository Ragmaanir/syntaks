require "../../spec_helper"

module OptionalParserTests
  class AcceptanceTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        OptionalParser.new(StringParser.new("asd"))
      end
    end

    def test_full_match
      assert TestParser.new.call("asd").full_match?
      assert TestParser.new.call("").full_match?
    end

    def test_result
      r = TestParser.new.call("123") as ParseSuccess(Nil)
      assert r.value == nil
    end

  end

  class ResultTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        OptionalParser.new(
          SequenceParser.new(
            TokenParser.new("number ", ->(token : Token){ token.content }),
            TokenParser(Int32).new(/[0-9]+/, ->(token : Token){ token.content.to_i })
          )
        )
      end
    end

    def test_ast_on_match
      r = TestParser.new.call("number 1") as ParseSuccess(Tuple(String, Int32)?)
      assert r.value == {"number ", 1}
    end

    def test_ast_on_mismatch
      r = TestParser.new.call("") as ParseSuccess(Tuple(String, Int32)?)
      assert r.value == nil
    end
  end
end
