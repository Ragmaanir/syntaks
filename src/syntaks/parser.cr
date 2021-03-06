module Syntaks
  abstract class Parser
    include EBNF

    abstract def root : Component

    def call!(input : String)
      src = Source.new(input)
      ctx = LoggingContext.new(ParseLog.new(src))
      r = call(src, ctx)
      puts ctx.parse_log
      r
    end

    def call!(src : Source)
      ctx = LoggingContext.new(ParseLog.new(src))
      r = call(src, ctx)
      puts ctx.parse_log
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

    def profile(input : String | Source)
      ctx = ProfilingContext.new
      res = call(input, ctx)
      puts ctx
      res
    end

    def inspect(io)
      # Override to avoid large output
      io << "#{self.class.name}"
    end
  end
end
