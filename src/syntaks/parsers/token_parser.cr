module Syntaks
  module Parsers

    class TokenParser(T) < Parser(T)
      getter token

      def self.new(token : String | Regex)
        TokenParser(String).new(token, ->(s : String){ s })
      end

      def initialize(@token : String | Regex, @action : String -> T)
      end

      #def call(state : ParseState) : ParseResult(T)
      def call(state : ParseState)
        parsed_text = case t = @token
        when String
          t if state.remaining_text.starts_with?(t)
        when Regex
          if m = Regex.new("\\A"+t.source).match(state.remaining_text)
            m[0]
          end
        end

        if parsed_text
          end_state = state.forward(parsed_text.size)
          value = @action.call(parsed_text)
          succeed(state, end_state, value)
        else
          fail(state)
        end
      end

      def to_ebnf
        @token.inspect
      end

      def to_structure
        "TokenParser(#{@token.inspect})"
      end

    end
  end
end
