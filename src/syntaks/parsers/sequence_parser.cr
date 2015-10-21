module Syntaks
  module Parsers

    class SequenceParser(L, R, T) < Parser(T)

      getter :left, :right, :action

      # def self.new(left : Parser(L), right : SequenceParser(X,Y,{X,Y}), &action : ((L,X,Y) -> T))
      #   SequenceParser(L, {X,Y}, T).new(left, right, ->(t : {L,{X,Y}}){ action.call(t[0], t[1][0], t[1][1]) })
      # end

      # def self.new(left : Parser(L), right : SequenceParser(X, Y, {X,Y}))
      #   SequenceParser(L, {X,Y}, {L,X,Y}).new(left, right, ->(t : {L,{X,Y}}){ {t[0], t[1][0], t[1][1] } })
      # end

      # def self.new(left : SequenceParser(A,B,{A,B}), right : SequenceParser(X,Y,{X,Y}), &action : ({A,B,X,Y} -> T))
      #   SequenceParser({A,B},{X,Y},T).new(left, right, action)
      # end

      def self.new(left : Parser(L), right : Parser(R), backtracking = true, &action : ({L,R} -> T))
        SequenceParser(L, R, T).new(left, right, action, backtracking)
      end

      def self.new(left : Parser(L), right : Parser(R), backtracking = true)
        SequenceParser(L, R, {L,R}).new(left, right, (->(t : {L,R}){ t }), backtracking)
      end

      def initialize(@left : Parser(L), @right : Parser(R), @action : ({L,R} -> T), @backtracking = true : Bool)
      end

      def call(state : ParseState) : ParseSuccess(T) | ParseFailure | ParseError
        left_result = @left.call(state)

        case left_result
        when ParseSuccess(L)
          right_result = @right.call(left_result.end_state)

          case right_result
          when ParseSuccess(R)
            value = @action.call({left_result.value, right_result.value})
            succeed(state, right_result.end_state, value)
          when ParseFailure
            #fail(state, left_result.end_state)
            if @backtracking
              fail(state, right_result.last_success || left_result)
            else
              error(state)
              #fail(state)
            end
          else
            right_result
          end
        when ParseFailure
          fail(state, left_result.last_success)
        else
          error(state)
          #fail(state)
        end
      end

      def to_ebnf
        "#{@left.to_ebnf} #{@right.to_ebnf}"
      end

      def to_structure
        "SequenceParser(#{left.to_structure}, #{right.to_structure})"
      end
    end

  end
end
