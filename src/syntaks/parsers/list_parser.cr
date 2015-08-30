module Syntaks
  module Parsers

    class ListParser(T) < Parser
      def initialize(@parser : Parser, @seperator_parser : Parser)
        @sequence = SequenceParser(Node).new([@seperator_parser, @parser]) do |args|
          args[1]
        end
      end

      def call(state : ParseState) : ParseResult
        case res = @parser.call(state)
        when ParseSuccess
          results = [res] + parse_tail(res.end_state)

          final_state = results.last.end_state as ParseState
          children = results.map{ |r| r.node as Node }

          node = T.new(children)

          succeed(state, final_state, node)
        when ParseFailure
          fail(state)
        else raise "Unknown parse result"
        end
      end

      private def parse_tail(state : ParseState) : Array(ParseSuccess)
        success = true
        results = [] of ParseSuccess
        current_state = state

        while success
          res = @sequence.call(current_state)

          case res
          when ParseSuccess
            results << res
            current_state = res.end_state
          when ParseFailure
            success = false
          end
        end

        results
      end

    end

  end
end
