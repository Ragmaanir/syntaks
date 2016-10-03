module Syntaks
  class SourceLocation
    include Kontrakt

    getter source : Source
    getter at : Int32

    def initialize(@source : Source, @at : Int)
      precondition(at >= 0)
      precondition(at < source.size)
    end

    def line_number
      source[0..at].count("\n")
    end

    def column_number
      at - (source[0..at].rindex("\n") || 0)
    end

    def line
      source[line_start..line_end]
    end

    def line_start
      @line_start ||= source[0..at].rindex("\n") || 0
    end

    def line_end
      # @line_end ||= line_start + (source[line_start..-1].index("\n") || 0)
      line_start + (source[line_start..-1].index("\n") || 0)
      # FIXME memoization. causes type errors ATM
    end

    def to_s(io)
      io << "#{line_number}:#{column_number}"
    end
  end
end
