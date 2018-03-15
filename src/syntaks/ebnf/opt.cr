module Syntaks
  module EBNF
    class Opt(V) < Component(V?)
      getter rule : Component(V)

      def initialize(@rule : Component(V))
      end

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(V?) | Failure | Error
        case r = rule.call(state, ctx)
        when Success
          Success(V?).new(state, r.end_state, r.value)
        when Failure
          Success(V?).new(state, state, nil)
        else r
        end
      end

      def simple?
        true
      end

      def ==(other : Opt)
        other.rule == rule
      end

      def to_s(io)
        str = if rule.simple?
                "~#{rule}"
              else
                "~(#{rule})"
              end
        io << str
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end
  end
end
