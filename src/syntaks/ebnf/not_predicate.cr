module Syntaks
  module EBNF
    class NotPredicate(V) < Component(Nil)
      getter rule : Component(V)

      def initialize(@rule : Component(V))
      end

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(Nil) | Failure | Error
        case res = rule.call(state, ctx)
        when Success
          Failure.new(state, self)
        else
          Success(Nil).new(state, res.end_state, nil)
        end
      end

      def simple?
        true
      end

      def ==(other : self)
        other.rule == rule
      end

      def to_s(io)
        io << "-"
        rule.to_s(io)
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end
  end
end
