module Syntaks
  module EBNF
    abstract class AbstractComponent
    end

    abstract class Component(V) < AbstractComponent
      def short_name
        # self.class.name.split("::").last
        self.class.name.gsub("Syntaks::", "")
      end

      abstract def simple? : Boolean
      abstract def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error

      def as_component
        self.as(Component(V))
      end

      private def succeed(state : State, end_state : State, value : V, ctx : Context) : Success(V)
        ctx.on_success(self, state, end_state)
        Success(V).new(end_state, value)
      end

      private def fail(state : State, ctx : Context) : Failure
        ctx.on_failure(self, state)
        Failure.new(state)
      end

      private def error(state : State, ctx : Context) : Error
        ctx.on_error(self, state)
        Error.new(state)
      end
    end
  end
end
