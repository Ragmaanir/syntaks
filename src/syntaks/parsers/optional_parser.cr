module Syntaks
  module Parsers

    class OptionalParser(T) < Parser(T?)
      def initialize(@parser : Parser(T))
      end

      def call(state : ParseState)
        case res = @parser.call(state)
        when ParseSuccess
          succeed(state, res.end_state, res.value)
        else
          succeed(state, state, nil)
        end
      end

      def to_ebnf
        @parser.to_ebnf.surround("[", "]")
      end
    end

  end
end
