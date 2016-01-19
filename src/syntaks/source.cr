module Syntaks

  class Source

    getter :at

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

  class SourceInterval

    getter :from, :length

    def initialize(@from : Int, @length=0 : Int)
    end

    def to
      from + length
    end

    def to_s
      "SourceInterval(#{from},#{length})"
    end
  end

end
