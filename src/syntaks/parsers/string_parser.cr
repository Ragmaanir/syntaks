module Syntaks
  module Parsers

    class StringParser < Parser
      def initialize(@string)
      end

      def call(state : ParseState) : ParseResult
        if state.remaining_text.starts_with?(@string)
          interval = state.interval(@string.length)
          end_state = state.forward(interval.length)
          node = IgnoredNode.new(state, interval)
          succeed(state, end_state, node)
        else
          fail(state)
        end
      end

      def to_s
        "#{canonical_name}(#{@string.inspect})"
      end
    end

  end
end
