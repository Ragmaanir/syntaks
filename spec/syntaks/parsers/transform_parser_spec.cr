require "../../spec_helper"

module TransformParserTests
  class AcceptanceTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        TransformParser.build(TokenParser.build(/[1-9][0-9]*/)) do |token|
          token.content.to_i
        end
      end
    end

    def test_full_match
      assert TestParser.new.call("100").full_match?
      assert TestParser.new.call("1").full_match?
    end

    def test_failure
      assert !TestParser.new.call("").full_match?
      assert !TestParser.new.call("test").full_match?
    end

    def test_result
      r = TestParser.new.call("123") as ParseSuccess(Int32)
      assert r.value == 123
    end

  end

  class ResultTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        TransformParser.build(
          SequenceParser.new(
            TokenParser.new("number ", ->(token : Token){ token.content }),
            TokenParser(Int32).new(/[0-9]+/, ->(token : Token){ token.content.to_i })
          )
        ) do |tuple|
          tuple[1]
        end
      end
    end

    def test_ast_on_match
      r = TestParser.new.call("number 1") as ParseSuccess(Int32)
      assert r.value == 1
    end

    def test_ast_on_mismatch
      r = TestParser.new.call("")
      assert !r.success?
    end
  end
end
