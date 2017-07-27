module Syntaks
  class Token
    getter interval : SourceInterval

    delegate content, to: interval

    def initialize(@interval)
    end

    def to_s(io)
      io << "Token(#{interval}, #{content.inspect})"
    end

    def inspect(io)
      to_s(io)
    end
  end
end
