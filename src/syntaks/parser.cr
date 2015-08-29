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
      "ParseState(#{at}, '#{source[at, 12]}...')"
    end

  end

  abstract class Parser
    abstract def call(state : ParseState) : ParseResult

    private def succeed(state, end_state, node)
      state.logger.debug "SUCCESS(#{self.to_s}): #{end_state.inspect}"
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
      self.class.name.split("::").last
    end
  end

end
