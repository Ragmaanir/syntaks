module Syntaks
  class Source
    @reversed_newline_indices : Array(Int32)
    getter newline_indices = [] of Int32

    delegate size, byte_slice, to: @content

    def initialize(@content : String)
      byte_idx = 0

      @content.each_char do |char|
        if char == '\n'
          @newline_indices << byte_idx
        end

        byte_idx += char.bytesize
      end

      @reversed_newline_indices = newline_indices.reverse
    end

    def find_leading_newline_idx_at_byte(at : Int)
      if idx = @reversed_newline_indices.bsearch_index { |pos| pos < at }
        # reverse idx because it is an index into our reversed array
        (newline_indices.size - 1) - idx
      end
    end

    # 0..newline_indices.size
    def line_number_at_byte(at : Int)
      raise IndexError.new if at >= size

      if idx = find_leading_newline_idx_at_byte(at)
        idx + 1
      else
        0
      end
    end

    # 0..*
    def column_number_at_byte(at : Int)
      raise IndexError.new if at >= size

      at - line_start_at_byte(at)
    end

    def line_start_at_byte(at : Int)
      raise IndexError.new if at >= size

      if newline_idx = find_leading_newline_idx_at_byte(at)
        newline_indices[newline_idx] + 1
      else
        0
      end
    end

    def line_end_at_byte(at : Int)
      raise IndexError.new if at >= size

      if newline_idx = newline_indices.bsearch_index { |pos| pos >= at }
        newline_indices[newline_idx]
      else
        size - 1
      end
    end

    def byte_slice(range : Range)
      byte_slice(range.min, range.max - range.min)
    end

    def peek(at : Int, length : Int)
      @content.byte_slice(at, length)
    end

    def check(at : Int, regex : Regex)
      match = regex.match_at_byte_index(@content, at, Regex::Options::ANCHORED)

      if match
        byte_slice(at, match.byte_end(0).to_i - at)
      end
    end

    def slow_lookup(from, length) : String
      @content[from, length]
    end

    def slow_lookup(range : Range) : String
      @content[range]
    end
  end
end
