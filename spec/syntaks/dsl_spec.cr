require "../spec_helper"

module SyntaksDSLTests
  class SequenceMacroTests < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks::DSL

      rule(:root) do
        sequence(str("first"), space, str("last"))
      end

      token(:space, /\s+/)
    end

    def test_types
      assert typeof(TestParser.new.root) == Syntaks::Parsers::ParserReference({String,{Nil,String}})
      assert typeof(TestParser.new.space) == Syntaks::Parsers::ParserReference(Nil)
      assert TestParser.new.call("first   last").success?
    end
  end
end
