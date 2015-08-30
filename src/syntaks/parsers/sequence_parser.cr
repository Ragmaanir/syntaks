module Syntaks
  module Parsers

    class SequenceParser(T) < Parser
      def initialize(@seq : Array(Parser), &@block : Array(Node) -> T)
      end

      def call(state : ParseState) : ParseResult
        at = state.at
        results = call_children(state)

        if results.length == @seq.length
          nodes = results.map{ |r| r.node as Node }

          final_state = results.last.end_state as ParseState

          node = @block.call(nodes) as T
          succeed(state, final_state, node)
        else
          fail(state)
        end
      end

      private def call_children(state : ParseState) : Array(ParseSuccess)
        results = [] of ParseSuccess
        current_state = state

        @seq.find do |parser|
          case result = parser.call(current_state)
          when ParseSuccess
            results << result
            current_state = result.end_state
            false
          when ParseFailure
            true
          end
        end

        results
      end
    end

  end
end
