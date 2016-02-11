require "../../spec_helper"

module SequenceParserTests

  class NestedParsersTest < Minitest::Test
    class TestParser < Syntaks::FullParser

      def root
        @root ||= SequenceParser.new(
          TokenParser.build("this "),
          SequenceParser.new(
            TokenParser.build("is "),
            SequenceParser.new(
              TokenParser.build("a "),
              TokenParser.build("sentence")
            )
          )
        )
      end
    end

    def test_acceptance
      assert TestParser.new.call("this is a sentence").full_match?
    end

    def test_partial_match?
      assert TestParser.new.call("this is a sentence with some extra stuff").partial_match?
    end
  end

  class ActionTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root ||= SequenceParser.new(
          TokenParser.build(/[1-9][0-9]*/),
          TokenParser.build(/[a-z]+/)
        ) do |args|
          {args[0].content.to_i, args[1].content}
        end
      end
    end

    def test_semantic_action
      assert typeof(TestParser.new.root) == Syntaks::Parsers::SequenceParser(Token, Token, {Int32, String})
      res = TestParser.new.call("1337woof") as Syntaks::ParseSuccess
      assert res.value == {1337, "woof"}
    end
  end

  class NestedActionTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        SequenceParser.new(
          TokenParser.build(/[1-9][0-9]*/),
          SequenceParser.new(
            TokenParser.build(","),
            TokenParser.build(/[a-z]+/)
          ) do |args|
            nil
          end
        )
      end
    end

    def test_nested_actions
      assert typeof(TestParser.new.root) == Syntaks::Parsers::SequenceParser(Token, Nil, {Token, Nil})
    end
  end

end
