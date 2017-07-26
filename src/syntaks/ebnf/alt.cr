module Syntaks
  module EBNF
    class Alt(L, R, V) < Component(V)
      getter left : Component(L)
      getter right : Component(R)

      def self.build(*args)
        new(*args)
      end

      def self.build(left : Component(L), right : Component(R))
        Alt(L, R, L | R).new(left, right)
      end

      def initialize(@left : Component(L), @right : Component(R), @action : V -> V = ->(v : V) { v })
      end

      def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        case lr = left.call(state, ctx)
        when Success
          succeed(state, lr.end_state, lr.value, ctx)
        when Failure
          case rr = right.call(state, ctx)
          when Success then succeed(state, rr.end_state, rr.value, ctx)
          when Failure then fail(rr.end_state, ctx)
          else              error(rr.end_state, ctx)
          end
        else error(state, ctx)
        end
      end

      def simple?
        false
      end

      def ==(other : Alt)
        other.left == left && other.right == right
      end

      def to_s(io)
        io << "#{left} | #{right}"
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end
  end
end
