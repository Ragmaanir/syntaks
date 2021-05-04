module Syntaks
  class Source
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
    end

    def find_leading_newline_idx_at_byte(at : Int32)
      # FIXME: how to reverse bsearch?
      # Creating a range from -size..0 to bsearch in reverse for now.
      (-(newline_indices.size - 1)..0).bsearch { |idx| newline_indices[idx.abs] < at }.try(&.abs)
    end

    # 0..newline_indices.size
    def line_number_at_byte(at : Int32)
      return 0 if at == 0 && size == 0
      raise IndexError.new if at >= size

      if idx = find_leading_newline_idx_at_byte(at)
        idx + 1
      else
        0
      end
    end

    # 0..*
    def column_number_at_byte(at : Int32)
      return 0 if at == 0 && size == 0
      raise IndexError.new if at >= size

      at - line_start_at_byte(at)
    end

    def line_start_at_byte(at : Int32)
      raise IndexError.new if at >= size

      if newline_idx = find_leading_newline_idx_at_byte(at)
        newline_indices[newline_idx] + 1
      else
        0
      end
    end

    def line_end_at_byte(at : Int32)
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

    def peek(at : Int32, length : Int32)
      @content.byte_slice(at, length)
    end

    def check(at : Int32, regex : Regex)
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

    def inspect(io)
      # Override to avoid large output
      io << "#{self.class.name}"
    end
  end
end
