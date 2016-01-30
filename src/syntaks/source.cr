module Syntaks
  class Source

    getter at

    def initialize(@data : String)
    end

    def [](from, length)
      @data[from, length]
    end

    def [](range : Range)
      @data[range]
    end

    def length
      @data.size
    end

  end
end
