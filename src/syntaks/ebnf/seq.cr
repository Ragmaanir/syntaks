module Syntaks
  module EBNF
    class Seq(L, R, V) < Component(V)
      getter left : Component(L)
      getter right : Component(R)
      getter backtracking : Bool

      def self.build(left : Component(L), right : Component(R), backtracking : Bool = false, &action : (L, R) -> V)
        Seq(L, R, V).new(left, right, backtracking, ->(l : L, r : R) { action.call(l, r) })
      end

      # def self.build(left : Component(L), right : Component(R), backtracking : Bool, action : (L, R) -> V)
      #   new(left, right, backtracking, action)
      # end

      def self.build(left : Component(L), right : Component(R), backtracking : Bool = false)
        Seq(L, R, {L, R}).new(left, right, backtracking, ->(l : L, r : R) { {l, r} })
      end

      def initialize(@left : Component(L), @right : Component(R), @backtracking, @action : (L, R) -> V)
      end

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        case lr = left.call(state, ctx)
        when Success
          case rr = right.call(lr.end_state, ctx)
          when Success
            Success(V).new(state, rr.end_state, @action.call(lr.value, rr.value))
          when Failure
            if backtracking
              Failure.new(rr.end_state, self)
            else
              Error.new(rr.end_state, self)
            end
          else
            rr
          end
        when Failure
          Failure.new(state, self)
        else
          lr
        end
      end

      def simple?
        false
      end

      def ==(other : Seq)
        other.left == left && other.right == right
      end

      def to_s(io)
        operator = case backtracking
                   when true then ">>"
                   else           "&"
                   end

        io << "#{left} #{operator} #{right}"
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end
  end
end
