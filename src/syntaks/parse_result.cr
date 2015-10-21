module Syntaks

  abstract class ParseResult
    getter :state, :parser

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

    getter :value, :end_state

    def initialize(@parser : Parser, @state : ParseState, @end_state : ParseState, @value : V)
    end

    def success?
      true
    end

    def full_match?
      end_state.at == end_state.source.length
    end

    def inspect
      "ParseSuccess(#{@parser.to_ebnf}, #{@state.inspect}, #{@end_state.inspect})"
    end
  end

  class ParseFailure < ParseResult

    getter :last_success

    def initialize(@parser : Parser, @state : ParseState, @last_success : ParseSuccess?)
      @end_state = @state
    end

    def success?
      false
    end

    def full_match?
      false
    end

    def inspect
      # FIXMW parser ist not the parser used to parse last_success
      #"ParseFailure(#{@state.inspect})"
      "ParseFailure(#{@last_success.inspect}, #{@parser.to_ebnf})"
    end

  end

  class ParseError < ParseResult

    def initialize(@parser : Parser, @state : ParseState)
      @end_state = @state
    end

    def success?
      false
    end

    def full_match?
      false
    end

    def inspect
      "ParseError"
    end

  end

end
