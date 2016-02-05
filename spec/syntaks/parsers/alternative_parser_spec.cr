require "../../spec_helper"

module AlternativeParserTests
  class NestedParsersTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root = AlternativeParser.new(
          TokenParser.new(/[1-9][0-9]*/, ->(token : Token){ token.content.to_i }),
          AlternativeParser.new(
            TokenParser.new(/[A-Z]+/),
            TokenParser.new(/[a-z]+/)
          )
        )
      end
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::AlternativeParser(Int32, Token, Token | Int32)
    end

    def test_full_match
      assert TestParser.new.call("1337").full_match?
      assert TestParser.new.call("asd").full_match?
      assert TestParser.new.call("XYZ").full_match?
    end

    def test_partial_match
      assert TestParser.new.call("1337test").partial_match?
    end

    def test_no_match
      assert !TestParser.new.call("").success?
      assert !TestParser.new.call("001337").success?
      assert !TestParser.new.call("---asd").success?
    end
  end

  class ValueGenerationTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root ||= AlternativeParser.new(
          TokenParser.new(/[1-9][0-9]*/, ->(token : Token){ token.content.to_i }),
          AlternativeParser.new(
            TokenParser.new(/0\.[0-9]+/, ->(token : Token){ token.content.to_f }),
            TokenParser.new(/[a-zA-Z]+/, ->(token : Token){ token.content })
          )
        )
      end
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::AlternativeParser(Int32, String | Float64, String | Float64 | Int32)
    end

    def test_int_value
      res = TestParser.new.call("1337") as Syntaks::ParseSuccess
      assert res.value == 1337
    end

    def test_float_value
      res = TestParser.new.call("0.1337") as Syntaks::ParseSuccess
      assert res.value == 0.1337
    end

    def test_string_value
      res = TestParser.new.call("test") as Syntaks::ParseSuccess
      assert res.value == "test"

      res = TestParser.new.call("ABC") as Syntaks::ParseSuccess
      assert res.value == "ABC"
    end
  end
end
