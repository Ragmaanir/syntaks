require "../../spec_helper"

module SequenceParserTests
  class NestedParsersTest < Minitest::Test
    class TestParser < Syntaks::FullParser

      def root
        @root ||= SequenceParser.new(
          TokenParser.new("this "),
          SequenceParser.new(
            TokenParser.new("is "),
            SequenceParser.new(
              TokenParser.new("a "),
              TokenParser.new("sentence")
            )
          )
        )
      end
    end

    def test_acceptance
      assert !TestParser.new.call("").success?
      assert !TestParser.new.call("this is").success?
      assert TestParser.new.call("this is a sentence").full_match?
    end

    def test_partial_match?
      assert TestParser.new.call("this is a sentence with some extra stuff").partial_match?
    end
  end
end
