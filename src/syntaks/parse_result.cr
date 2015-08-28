module Syntaks

  abstract class ParseResult
    getter :state, :interval, :parser

    def initialize(@state, @interval, @parser)
    end

    abstract def success?
  end

  class ParseSuccess < ParseResult
    getter :node

    def initialize(@state, @interval, @parser, @node)
    end

    def success?
      true
    end
  end

  class ParseFailure < ParseResult

    def initialize(@state, @parser)
      @interval = SourceInterval.new(state.source, state.at, 0)
    end

    def success?
      false
    end
  end

end
