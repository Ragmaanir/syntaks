module Syntaks
  module Parsers
    class NotPredicate(T) < Parser(Nil)

      getter parser

      def initialize(@parser : Parser(T))
      end

      def call(state : ParseState)
        res = parser.call(state)

        case res
          when ParseSuccess
            fail(state)
          else
            succeed(state, state, nil)
        end
      end

      def to_ebnf
        "Not(#{parser.to_ebnf})"
      end

      def to_structure
        "NotPredicate(#{parser.to_structure})"
      end

    end
  end
end
