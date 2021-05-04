module Syntaks
  class SourceInterval
    include Kontrakt

    getter source : Source
    getter from : Int32
    getter length : Int32
    getter content : String

    # # interval does not include last character
    # private def initialize(@source, @from, @length = 0)
    #   precondition(from >= 0)
    #   precondition(length >= 0)
    #   precondition(to < source.size)
    # end

    # def initialize(@source, @from, content : String)
    #   initialize(source, from, content.size)
    #   @cached_content = content
    # end

    # interval does not include last character
    def initialize(@source, @from, @content : String)
      precondition(from >= 0)

      @length = @content.size

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

    # def content : String
    #   @cached_content || begin
    #     c = source.slow_lookup(from..to)
    #     @cached_content = c
    #     c
    #   end
    # end

    def to_s(io)
      io << "SourceInterval(#{from_location},#{to_location})"
    end

    def inspect(io)
      to_s(io)
    end
  end
end
