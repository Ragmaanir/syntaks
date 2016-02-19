require "../spec_helper"

module SyntaksDSLTests
  class SequenceMacroTests < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks::DSL

      rule(:root) do
        sequence(str("first"), space, str("last"))
      end

      ignored_token(:space, /\s+/)
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::ParserReference({Syntaks::Token,{Nil,Syntaks::Token}})
      assert typeof(TestParser.new.space) == Syntaks::Parsers::ParserReference(Nil)
    end

    def test_parsing
      assert TestParser.new.call("first   last").success?
      assert !TestParser.new.call("first").success?
    end
  end

  class AlternativeMacroTests < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks::DSL

      rule(:root) do
        alternatives(string, int) do |int_or_string|
          int_or_string
        end
      end

      token(:int, /[1-9][0-9]*/) do |t|
        t.content.to_i
      end

      token(:string, /[a-zA-Z]+/) do |t|
        t.content
      end

    end

    def test_types
      assert typeof(TestParser.new.root) == Parsers::ParserReference(String | Int32)
      assert typeof(TestParser.new.int) == Parsers::ParserReference(Int32)
    end

    def test_parsing
      assert TestParser.new.call("second").success?
      assert !TestParser.new.call("$%&").success?
      assert TestParser.new.call("1332").success?
    end

    def test_results
      res = TestParser.new.call("second") as ParseSuccess
      assert res.value == "second"

      res = TestParser.new.call("1332") as ParseSuccess
      assert res.value == 1332
    end
  end

  class TransformMacroTests < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks::DSL

      rule(:root) do
        trans
      end

      transform(:trans, int) do |t|
        t.content.to_i
      end

      token(:int, /[1-9][0-9]*/)
    end

    def test_result
      res = TestParser.new.call("123") as ParseSuccess
      assert res.value == 123
    end
  end
end
