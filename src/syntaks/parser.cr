module Syntaks
  abstract class Parser

    include EBNF

    abstract def root : Component

    def call(input : String)
      call(Source.new(input))
    end

    def call(source : Source)# : Success | Failure | Error
      root.call(State.new(source, 0))
    end

  end
end
