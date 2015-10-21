module Syntaks
  module Parsers

    class AlternativeParser(L, R, T) < Parser(T)

      def self.new(left : Parser(L), right : Parser(R))
        AlternativeParser(L, R, L | R).new(left, right, true)
      end

      def initialize(@left : Parser(L), @right : Parser(R), ignored : Bool)
      end

      def call(state : ParseState)
        left_result = @left.call(state)

        case left_result
        when ParseSuccess(L)
          left_value = left_result.value
          succeed(state, left_result.end_state, left_value)
        when ParseFailure
          right_result = @right.call(state)

          case right_result
          when ParseSuccess(R)
            right_value = right_result.value
            succeed(state, right_result.end_state, right_value)
          when ParseFailure
            fail(state, left_result.last_success || right_result.last_success)
          else
            #error(state)
            fail(state)
          end
        else
          #error(state)
          fail(state)
        end
      end

      def to_ebnf
        "#{@left.to_ebnf} | #{@right.to_ebnf}"
      end
    end

  end
end
