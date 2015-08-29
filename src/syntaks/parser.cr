require "logger"

module Syntaks

  class ParseState

    getter :source, :at
    getter :logger

    def initialize(@source : Source, @at = 0, @logger = Logger.new(STDOUT))
      @logger.level = Logger::Severity::DEBUG
    end

    def interval(n : Int)
      SourceInterval.new(source, at, n)
    end

    def forward(n : Int)
      #ParseState.new(source, at + n)
      @at += n
    end

    def to_s
      source[at..-1]
    end

  end

  abstract class Parser
    abstract def call(state : ParseState) : ParseResult

    private def succeed(state, interval, node)
      state.logger.debug "SUCCESS(#{self.to_s}): #{interval.to_s}"
      ParseSuccess.new(state, interval, self, node)
    end

    private def fail(state)
      state.logger.debug "FAIL(#{self.to_s}): #{state.at}"
      ParseFailure.new(state, self)
    end

    def to_s
      self.class.name
    end
  end

end
