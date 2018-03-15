module Syntaks
  module EBNF
    abstract class AbstractComponent
    end

    abstract class Component(V) < AbstractComponent
      def short_name
        self.class.name.gsub("Syntaks::EBNF::", "").split("(").first
      end

      abstract def simple? : Boolean

      def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        ctx.start_component_call(self, state)
        res = call_impl(state, ctx)
        ctx.end_component_call(self, state, res)
        res
      end

      abstract def call_impl(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error

      def as_component
        self.as(Component(V))
      end
    end
  end
end
