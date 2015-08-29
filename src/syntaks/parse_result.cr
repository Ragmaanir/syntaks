module Syntaks

  abstract class ParseResult
    getter :state, :interval, :parser

    abstract def success?
  end

  class ParseSuccess < ParseResult
    getter :node

    def initialize(@state : ParseState, @interval : SourceInterval, @parser : Parser, @node : Node)
    end

    def success?
      true
    end
  end

  class ParseFailure < ParseResult

    def initialize(@state : ParseState, @parser : Parser)
      @interval = SourceInterval.new(state.source, state.at, 0)
    end

    def success?
      false
    end
  end

end
