module Syntaks
  class SourceInterval
    include Kontrakt

    getter source : Source
    getter from : Int32
    getter length : Int32

    def initialize(@source, @from, @length = 0)
      precondition(from >= 0)
      precondition(length >= 0)
      precondition(to < source.size)
    end

    def from_location
      SourceLocation.new(source, from)
    end

    def to_location
      SourceLocation.new(source, to)
    end

    def to
      from + length - 1
    end

    def content
      source[from..to]
    end

    def to_s(io)
      io << "SourceInterval(#{from_location},#{to_location})"
    end

    def inspect(io)
      to_s(io)
    end
  end
end
