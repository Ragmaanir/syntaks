module Syntaks
  module Parsers
    class ListParser(T) < Parser(Array(T))

      def initialize(@parser : Parser(T))
        @sequence = @parser
      end

      def initialize(@parser : Parser(T), seperator_parser : Parser(B))
        @seperator_parser = seperator_parser
        @sequence = SequenceParser.new(
          seperator_parser,
          @parser,
          ->(value : {B, T}) { value[1] }
        )
      end

      def call(state : ParseState)
        case res = @parser.call(state)
        when ParseSuccess(T)
          #tail_results, last_success = parse_tail(res.end_state)
          #results = [res] + tail_results
          results = [res] + parse_tail(res.end_state)

          final_state = results.last.end_state as ParseState
          value = results.map{ |r| r.value }

          succeed(state, final_state, value)
        when ParseFailure
          fail(state, res.last_success)
        else
          #error(state)
          fail(state)
        end
      end

      private def parse_tail(state : ParseState)
        success = true
        results = [] of ParseSuccess(T)
        current_state = state
        last_success = nil

        while success
          res = @sequence.call(current_state)

          # case res
          # when ParseSuccess(T)
          #   results << res
          #   current_state = res.end_state
          # when ParseFailure, ParseError
          #   success = false
          #   last_success = res.last_success
          # end

          if res.is_a?(ParseSuccess(T))
            results << res
            current_state = res.end_state
          elsif res.is_a?(ParseFailure)
            success = false
            last_success = res.last_success
          end
        end

        #{results, last_success}
        results
      end

      def to_ebnf
        if sep = @seperator_parser
          "list(#{@parser.to_ebnf}, #{sep.to_ebnf})"
        else
          "list(#{@parser.to_ebnf})"
        end
      end

      def to_structure
        "ListParser(#{parser.to_structure}, #{seperator_parser.to_structure})"
      end

    end
  end
end
