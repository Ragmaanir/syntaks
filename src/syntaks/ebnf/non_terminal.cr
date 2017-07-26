module Syntaks
  module EBNF
    class NonTerminal(R, V) < Component(V)
      getter name : String
      # getter referenced_rule : (-> Component(V)) | (-> Terminal(V)) | (-> NonTerminal(V))
      getter referenced_rule : (-> Component(R))
      getter action : R -> V

      def self.build(name : String, referenced_rule : -> Component(R))
        NonTerminal(R, R).new(name, referenced_rule, ->(v : R) { v })
      end

      def self.build(name : String, referenced_rule : -> Component(R), &action : R -> V)
        NonTerminal(R, V).new(name, referenced_rule, action)
      end

      def initialize(@name, @referenced_rule, @action)
      end

      def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        ctx.on_non_terminal(self, state)
        r = referenced_rule.call.call(state, ctx)
        case r
        when Success(R) then succeed(state, r.end_state, action.call(r.value), ctx)
        else
          fail(state, ctx)
        end
      end

      def simple?
        true
      end

      def ==(other : NonTerminal)
        other.name == name
      end

      def to_s(io)
        io << name
      end

      def inspect(io)
        io << name
      end
    end
  end
end
