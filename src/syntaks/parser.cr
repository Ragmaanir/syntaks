module Syntaks
  abstract class Parser
    include EBNF

    abstract def root : Component

    def call!(input : String)
      src = Source.new(input)
      ctx = LoggingContext.new(ParseLog.new(src))
      r = call(src, ctx)
      case r
      when Failure, Error then puts ctx.parse_log
      end
      r
    end

    def call(input : String, ctx : Context = EmptyContext.new)
      call(Source.new(input), ctx)
    end

    def call(source : Source, ctx : Context = EmptyContext.new) # : Success | Failure | Error
      root.call(State.new(source, 0), ctx)
    end

    def call(state : State, ctx : Context = EmptyContext.new) # : Success | Failure | Error
      root.call(state, ctx)
    end
  end
end
