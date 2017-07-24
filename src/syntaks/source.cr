module Syntaks
  class Source
    getter content : String

    delegate size, to: content

    def initialize(@content)
    end

    def [](from, length)
      content[from, length]
    end

    def [](range : Range)
      content[range]
    end
  end
end
