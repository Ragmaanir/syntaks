module Syntaks

  abstract class ParseResult
    getter :state, :parser

    def initialize(@state : ParseState, @end_state : ParseState)
    end

    abstract def success? : Boolean
    def interval : SourceInterval
      SourceInterval.new(state.at, end_state.at)
    end
  end

  class ParseSuccess < ParseResult
    getter :node, :end_state

    def initialize(@state : ParseState, @end_state : ParseState, @parser : Parser, @node : Node)
    end

    def success?
      true
    end
  end

  class ParseFailure < ParseResult

    def initialize(@state : ParseState, @parser : Parser)
      @end_state = @state
    end

    def success?
      false
    end
  end

end
