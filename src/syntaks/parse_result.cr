module Syntaks

  abstract class ParseResult
    getter :state#, :parser

    def initialize(@state : ParseState, @end_state : ParseState)
    end

    abstract def success? : Boolean
    abstract def full_match? : Boolean

    def partial_match?
      success? && !full_match?
    end

    def interval : SourceInterval
      SourceInterval.new(state.at, end_state.at)
    end
  end

  class ParseSuccess(V) < ParseResult

    @value :: V

    getter :value, :end_state

    def initialize(parser : Parser, @state : ParseState, @end_state : ParseState, @value : V)
    end

    def success?
      true
    end

    def full_match?
      end_state.at == end_state.source.length
    end

    def inspect
      "ParseSuccess(#{@state}, #{@end_state})"
    end
  end

  class ParseFailure < ParseResult

    def initialize(parser : Parser, @state : ParseState)
      @end_state = @state
    end

    def success?
      false
    end

    def full_match?
      false
    end

    def inspect
      "ParseFailure(#{@state.inspect})"
    end
  end

end
