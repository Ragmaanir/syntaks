module Syntaks
  class Token

    getter interval

    delegate content, interval

    def initialize(@interval : SourceInterval)
    end

    def to_s(io)
      io << "Token(#{interval}, #{content.inspect})"
    end

    def inspect(io)
      to_s(io)
    end
    
  end
end
