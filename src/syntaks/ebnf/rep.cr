module Syntaks
  module EBNF
    class Rep(V) < Component(Array(V))
      getter rule : Component(V)

      def initialize(@rule : Component(V))
      end

      def call(state : State, ctx : Context = EmptyContext.new) : Success(Array(V)) | Failure | Error
        next_state = state
        values = [] of V
        result = rule.call(next_state, ctx)

        loop do
          case result
          when Success
            values << result.value
            next_state = result.end_state
            result = rule.call(next_state, ctx)
          when Failure
            break
          else
            return error(result.end_state, ctx)
          end
        end

        succeed(state, result.end_state, values, ctx)
      end

      def simple?
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
