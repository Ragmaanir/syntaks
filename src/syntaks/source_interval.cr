module Syntaks
  class SourceInterval

    include Kontrakt

    getter source, from, length

    def initialize(@source : Source, @from : Int, @length=0 : Int)
      precondition(from >= 0)
      precondition(length >= 0)
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

  end
end
