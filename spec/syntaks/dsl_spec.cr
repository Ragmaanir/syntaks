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
      assert typeof(TestParser.new.root) == Syntaks::Parsers::ParserReference({Syntaks::Token,{Nil,Syntaks::Token}},{Syntaks::Token,{Nil,Syntaks::Token}})
      assert typeof(TestParser.new.space) == Syntaks::Parsers::ParserReference(Nil, Nil)
      assert TestParser.new.call("first   last").success?
    end
  end

  class AlternativeMacroTests < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks::DSL

      rule(:root) do
        alternatives(str("first"), str("second"), str("xyz")) do |token|
          token.content
        end
      end

    end

    def test_types
      assert typeof(TestParser.new.root) == Parsers::ParserReference(String, String)
      assert TestParser.new.call("second").success?
      assert TestParser.new.call("xyz").success?
      assert !TestParser.new.call("aaa").success?
    end
  end
end
