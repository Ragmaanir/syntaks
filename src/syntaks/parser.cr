module Syntaks
  abstract class Parser

    include EBNF

    abstract def root

    def call(input : String)
      call(Source.new(input))
    end

    def call(source : Source)
      root.call(ParseState.new(source, 0))
    end

  end
end
