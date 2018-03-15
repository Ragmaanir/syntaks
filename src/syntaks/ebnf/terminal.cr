module Syntaks
  module EBNF
    class Terminal(V) < Component(V)
      alias Matcher = String | Regex
      getter matcher : Matcher

      def self.build(matcher : Matcher)
        new(matcher, ->(t : Token) { t })
      end

      def self.build(matcher : Matcher, action : Token -> V)
        new(matcher, action)
      end

      def initialize(@matcher, @action : Token -> V)
      end

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        parsed_text = case m = matcher
                      when String
                        m if state.remaining_text.starts_with?(m)
                      when Regex
                        if r = Regex.new("\\A(#{m.source})").match(state.remaining_text)
                          r[0]
                        end
                      end

        if parsed_text
          end_state = state.advance(parsed_text.size)
          token = Token.new(state.interval(parsed_text.size))
          value = @action.call(token)

          Success(V).new(state, end_state, value)
        else
          Failure.new(state, self)
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
