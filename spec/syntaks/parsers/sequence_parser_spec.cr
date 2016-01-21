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
      #r = TestParser.new.call("")
      #assert r.success?
      # assert !TestParser.new.call("").success?
      # assert !TestParser.new.call("this is").success?
      assert TestParser.new.call("this is a sentence").full_match?
    end

    def test_partial_match?
      # assert TestParser.new.call("this is a sentence with some extra stuff").partial_match?
    end
  end

  class ActionTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        @root ||= SequenceParser.new(
          TokenParser.new(/[1-9][0-9]*/),
          TokenParser.new(/[a-z]+/)
        ) do |args|
          {args[0].to_i, args[1]}
        end
      end
    end

    def test_semantic_action
      # assert typeof(TestParser.new.root) == Syntaks::Parsers::SequenceParser(String, String, {Int32, String})
      # res = TestParser.new.call("1337woof") as Syntaks::ParseSuccess
      # assert res.value == {1337, "woof"}
    end
  end

  class NestedActionTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      def root
        SequenceParser.new(
          TokenParser.new(/[1-9][0-9]*/),
          SequenceParser.new(
            TokenParser.new(","),
            TokenParser.new(/[a-z]+/)
          )
        ) do |args|
          nil
        end
      end
    end

    def test_nested_actions
      # assert TestParser.new.call("1337,test").success?
      # assert typeof(TestParser.new.root.action) == Proc({String, {String, String}}, Nil)
    end
  end

end
