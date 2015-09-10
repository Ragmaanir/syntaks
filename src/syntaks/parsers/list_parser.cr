module Syntaks
  module Parsers

    class ListParser(T) < Parser(Array(T))
      def initialize(@parser : Parser(T))
        @sequence = @parser
      end

      def initialize(@parser : Parser(T), @seperator_parser : Parser(B))
        @sequence = SequenceParser.new(@seperator_parser, @parser) do |value|
          value[0]
        end
      end

      def call(state : ParseState)
        case res = @parser.call(state)
        when ParseSuccess
          results = [res] + parse_tail(res.end_state)

          final_state = results.last.end_state as ParseState
          value = results.map{ |r| r.value }

          succeed(state, final_state, value)
        else
          fail(state)
        end
      end

      private def parse_tail(state : ParseState)
        success = true
        results = [] of ParseSuccess(T)
        current_state = state

        while success
          res = @sequence.call(current_state)

          case res
          when ParseSuccess
            results << res
            current_state = res.end_state
          else
            success = false
          end
        end

        results
      end

      def to_ebnf
        if @seperator_parser
          "list(#{@parser.to_ebnf})"
        else
          "list(#{@parser.to_ebnf}, #{@seperator_parser.to_ebnf})"
        end
      end

    end

  end
end
