module Syntaks
  module Parsers

    class TokenParser(T) < Parser(T)
      getter matcher

      def self.build(matcher : String | Regex)
        TokenParser(Token).new(matcher, ->(t : Token){ t })
      end

      def self.build(matcher : String | Regex, action : Token -> T)
        TokenParser(T).new(matcher, action)
      end

      def initialize(@matcher : String | Regex, @action : Token -> T)
      end

      def call(state : ParseState)
        parsed_text = case m = matcher
          when String
            m if state.remaining_text.starts_with?(m)
          when Regex
            if r = Regex.new("\\A"+m.source).match(state.remaining_text)
              r[0]
            end
        end

        if parsed_text
          end_state = state.forward(parsed_text.size)
          token = Token.new(state.interval(parsed_text.size))
          value = @action.call(token)
          succeed(state, end_state, value)
        else
          fail(state)
        end
      end

      def to_ebnf
        matcher.inspect
      end

      def to_structure
        "TokenParser(#{matcher.inspect})"
      end

    end
  end
end
