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

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        r = referenced_rule.call.call(state, ctx)

        case r
        when Success(R)
          Success(V).new(state, r.end_state, action.call(r.value))
        when Failure
          Failure.new(state, self)
        else
          r
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
