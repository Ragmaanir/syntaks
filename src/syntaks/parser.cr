require "logger"

module Syntaks

  class ParseState

    getter :source, :at
    getter :logger

    def initialize(@source : Source, @at = 0 : Int, @logger = Logger.new(STDOUT))
      @logger.level = Logger::Severity::DEBUG
    end

    def interval(n : Int)
      SourceInterval.new(at, n)
    end

    def forward(n : Int)
      raise ArgumentError.new("n==0") if n == 0
      ParseState.new(source, at + n, logger)
    end

    def remaining_text
      source[at..-1]
    end

    def inspect
      text = source[at, 12].colorize(:blue).bold.on(:dark_gray)
      "ParseState(#{at}, #{text})"
    end

  end

  abstract class Parser
    abstract def call(state : ParseState) : ParseResult

    private def succeed(state, end_state, node)
      diff = end_state.at - state.at
      parsed_text = state.remaining_text[0, diff].colorize(:white).bold.on(:green)
      remaining_text = end_state.remaining_text[0, 12].colorize(:white).on(:blue)

      state.logger.debug "SUCCESS(#{self.to_s}): #{parsed_text}#{remaining_text}"
      ParseSuccess.new(state, end_state, self, node)
    end

    private def fail(state)
      state.logger.debug "FAIL(#{self.to_s}): #{state.at}"
      ParseFailure.new(state, self)
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
  end

end
