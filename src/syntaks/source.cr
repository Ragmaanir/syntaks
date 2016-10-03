module Syntaks
  class Source
    getter content

    delegate size, to: content

    def initialize(@content : String)
    end

    def [](from, length)
      content[from, length]
    end

    def [](range : Range)
      content[range]
    end
  end
end
