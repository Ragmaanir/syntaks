require "../../spec_helper"

module SyntaksSpec_AlternativeParser
  include Syntaks
  include Syntaks::Parsers

  class IntLit < TerminalNode
  end

  class StringLit < TerminalNode
  end

  class TestParser
    def root
      AlternativeParser.new([int, string])
    end

    def int
      TokenParser(IntLit).new(/[1-9][0-9]*/)
    end

    def string
      TokenParser(StringLit).new(/"[^"]*"/)
    end
  end

  describe AlternativeParser do
    it "" do
      parser = TestParser.new.root

      source = Syntaks::Source.new("1337")
      state = Syntaks::ParseState.new(source)

      assert parser.call(state).success?
    end
  end

end
