require "logger"

module Syntaks

  class ParseState

    getter :source, :at
    getter :logger

    def initialize(@source : Source, @at = 0 : Int, @logger = Logger.new(STDOUT))
    end

    def interval(n : Int)
      SourceInterval.new(at, n)
    end

    def forward(n : Int)
      raise ArgumentError.new("n<0") if n < 0
      ParseState.new(source, at + n, logger)
    end

    def remaining_text
      source[at..-1]
    end

    def current_line_start
      source[0..at].rindex("\n") || 0
    end

    def current_line
      if m = source[current_line_start..-1].match(/[^\n]*/)
        m[0].inspect
      else
        ""
        #source[current_line_start..-1][0,10]
        #raise current_line_start.to_s
        #raise "Regex is incorrect: #{source[current_line_start..-1]}"
      end
    end

    def line_number
      # PERFORMANCE cache this
      source[0..at].count("\n")
    end

    def column
      at - current_line_start
    end

    def inspect
      #text = source[at, 16].inspect.colorize(:blue).bold.on(:dark_gray)
      # text = remaining_text[/([^\n]*)/]
      # text = remaining_text[0, 32] if text.size < 10
      # FIXME print current line unless parsing failed at newline or so
      text = remaining_text[0, 32]
      text = text.inspect.colorize(:blue).bold.on(:dark_gray)
      "ParseState(#{at}, #{text})"
    end

  end

  abstract class Parser(T)
    #abstract def call(state : ParseState) : ParseSuccess(T) | ParseFailure | ParseError
    abstract def call(state : ParseState) : ParseResult

    private def succeed(state, end_state, value : T)
      diff = end_state.at - state.at
      parsed_text = state.remaining_text[0, diff].inspect[1..-2].colorize(:white).bold.on(:green)
      remaining_text = end_state.remaining_text[0, 12].inspect[1..-2].colorize(:white).on(:blue)

      state.logger.debug "SUCCESS(#{self.to_ebnf}): #{parsed_text}#{remaining_text}"
      ParseSuccess(T).new(self, state, end_state, value)
    end

    private def fail(state, last_success = nil : ParseSuccess?)
      state.logger.debug "FAIL(#{self.to_ebnf} in #{state.line_number}:#{state.column} : #{state.current_line})"
      ParseFailure.new(self, state, last_success)
    end

    private def error(state)
      ParseError.new(self, state)
      #ParseFailure.new(self, state, nil)
    end

    def to_s
      canonical_name
    end

    def canonical_name
      if self.class.name.includes?("(")
        if m = self.class.name.match(/.*::([a-zA-Z0-9]+\(.*)/)
          m[1]
        end
      else
        self.class.name.split("::").last
      end
    end

    abstract def to_ebnf : String
    abstract def to_structure : String
  end

end
