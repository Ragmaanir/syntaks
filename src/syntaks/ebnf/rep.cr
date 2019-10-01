module Syntaks
  module EBNF
    class Rep(V) < Component(Array(V))
      getter rule : Component(V)

      def initialize(@rule : Component(V))
      end

      def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(Array(V)) | Failure | Error
        last_state = state
        next_state = state
        values = [] of V
        result = rule.call(next_state, ctx)

        loop do
          case result
          when Success
            values << result.value
            last_state = next_state
            next_state = result.end_state

            result = rule.call(next_state, ctx)
          when Failure
            return Success(Array(V)).new(state, next_state, values)
          else
            return result
          end
        end
      end

      def simple? : Bool
        true
      end

      def ==(other : Rep)
        other.rule == rule
      end

      def to_s(io)
        io << "{#{rule}}"
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end
  end
end
