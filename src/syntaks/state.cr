module Syntaks
  class State

    include Kontrakt
    getter source : Source
    getter at     : Int32

    def initialize(@source : Source, @at : Int)
      precondition(at >= 0)
      precondition(at <= source.size)
    end

    def remaining_text
      source.content[at..-1]
    end

    def advance(n : Int)
      precondition(n >= 0)
      State.new(source, at + n)
    end

    def location
      SourceLocation.new(source, at)
    end

    def interval(length : Int)
      SourceInterval.new(source, at, length)
    end

    def display
      #text = source[at, 16].inspect.colorize(:blue).bold.on(:dark_gray)
      # text = remaining_text[/([^\n]*)/]
      # text = remaining_text[0, 32] if text.size < 10
      # FIXME print current line unless parsing failed at newline or so
      text = remaining_text[0, 32]
      text = text.inspect.colorize(:blue).bold.on(:dark_gray)
      "State(#{at}, #{text})"
    end

    def to_s(io)
      io << "State(#{at})"
    end

    def inspect(io)
      to_s(io)
    end

  end
end
