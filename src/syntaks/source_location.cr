module Syntaks
  class SourceLocation
    include Kontrakt

    getter source : Source
    getter at : Int32

    def initialize(@source, @at)
      precondition(at >= 0)
      precondition(at < source.size)
    end

    def line_number
      source.line_number_at_byte(at) + 1
    end

    def column_number
      source.column_number_at_byte(at) + 1
    end

    def line_start
      source.line_start_at_byte(at)
    end

    def line_end
      source.line_end_at_byte(at)
    end

    def line
      source.byte_slice(line_start..(line_end + 1))
    end

    def to_s(io)
      io << "#{line_number}:#{column_number}"
    end
  end
end
