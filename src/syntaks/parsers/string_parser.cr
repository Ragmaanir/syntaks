module Syntaks
  module Parsers
    class StringParser < Parser(Nil)

      def initialize(@string)
      end

      def call(state : ParseState)
        if state.remaining_text.starts_with?(@string)
          end_state = state.forward(@string.size)
          succeed(state, end_state, nil)
        else
          fail(state)
        end
      end

      def to_s(io)
        io << "#{canonical_name}(#{@string.inspect})"
      end

      def to_ebnf
        @string.inspect
      end

      def to_structure
        "StringParser(#{@string})"
      end

    end
  end
end
