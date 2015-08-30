module Syntaks
  module Parsers

    class TokenParser(T) < Parser
      getter :token

      def initialize(@token : String | Regex)
      end

      def call(state : ParseState) : ParseResult
        parsed_text = case t = @token
        when String
          t if state.remaining_text.starts_with?(t)
        when Regex
          if m = t.match(state.remaining_text)
            m[0]
          end
        end

        if parsed_text
          interval = state.interval(parsed_text.length)
          end_state = state.forward(parsed_text.length)
          node = T.new(state, interval)
          succeed(state, end_state, node)
        else
          fail(state)
        end
      end

      def to_ebnf
        @token.inspect
      end

    end
  end
end
