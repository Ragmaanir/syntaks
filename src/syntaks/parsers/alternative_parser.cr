module Syntaks
  module Parsers

    class AlternativeParser < Parser
      def initialize(@alternatives : Array(Parser))
      end

      def call(state : ParseState) : ParseResult
        result = nil

        @alternatives.find do |parser|
          res = parser.call(state)

          case res
          when ParseSuccess
            result = res
            true
          end
        end

        if result
          succeed(state, result.end_state, result.node)
        else
          fail(state)
        end
      end
    end

  end
end
