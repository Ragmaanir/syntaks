module Syntaks
  module EBNF
    class Terminal(V) < Component(V)
      getter matcher : String | Regex

      def self.build(matcher : String | Regex)
        new(matcher, ->(t : Token) { t })
      end

      def self.build(matcher : String | Regex, action : Token -> V)
        new(matcher, action)
      end

      def initialize(@matcher : String | Regex, @action : Token -> V)
      end

      def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        parsed_text = case m = matcher
                      when String
                        m if state.remaining_text.starts_with?(m)
                      when Regex
                        if r = Regex.new("\\A" + m.source).match(state.remaining_text)
                          r[0]
                        end
                      end

        if parsed_text
          end_state = state.advance(parsed_text.size)
          token = Token.new(state.interval(parsed_text.size))
          value = @action.call(token)
          succeed(state, end_state, value, ctx)
        else
          fail(state, ctx)
        end
      end

      def simple?
        true
      end

      def ==(other : Terminal)
        other.matcher == matcher
      end

      def to_s(io)
        io << matcher.inspect
      end

      def inspect(io)
        io << matcher.inspect
      end
    end
  end
end
