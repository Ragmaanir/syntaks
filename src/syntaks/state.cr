module Syntaks
  class State
    include Kontrakt
    getter source : Source
    getter at : Int32

    def initialize(@source, @at)
      precondition(at >= 0)
      precondition(at <= source.size)
    end

    def peek?(str : String)
      str if peek(str.size) == str
    end

    def peek(length : Int)
      source.peek(at, length)
    end

    def peek?(regex : Regex)
      source.check(at, regex)
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
      # FIXME print current line unless parsing failed at newline or so
      text = peek(32)
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
