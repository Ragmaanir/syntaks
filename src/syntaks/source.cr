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
  end

  class SourceInterval

    getter :source, :from, :length

    def initialize(@source : Source, @from, @length=0)
    end

    def to
      from + length
    end

    def to_s
      @source[@from, @length]
    end
  end

end
