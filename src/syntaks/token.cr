module Syntaks
  class Token
    getter interval

    def initialize(@interval : SourceInterval)
    end

    def content
      interval.content
    end
  end
end
