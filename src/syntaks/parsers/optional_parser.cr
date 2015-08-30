module Syntaks
  module Parsers

    class OptionalParser(N) < Parser
      def initialize(@parser)
      end

      def call(state : ParseState) : ParseResult
        case res = @parser.call(state)
        when ParseSuccess
          succeed(state, res.interval, N.new(res.node))
        when ParseFailure
          succeed(state, state.interval(0), N.new)
        end
      end
    end

  end
end
