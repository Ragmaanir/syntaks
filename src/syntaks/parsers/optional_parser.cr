module Syntaks
  module Parsers
    class OptionalParser(T) < Parser(T?)

      def initialize(@parser : Parser(T))
      end

      def call(state : ParseState)
        case res = @parser.call(state)
        when ParseSuccess
          succeed(state, res.end_state, res.value)
        when ParseFailure
          succeed(state, state, nil)
        else
          #error(state)
          fail(state)
        end
      end

      def to_ebnf
        #@parser.to_ebnf.surround("[", "]") # FIXME surround
        "[#{@parser.to_ebnf}]"
      end

      def to_structure
        "OptionalParser(#{parser.to_structure})"
      end

    end
  end
end
