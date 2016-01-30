require "../spec_helper"

module SourceIntervalTests
  class SourceIntervalTest < Minitest::Test

    def test_nonempty_lines
      s = Source.new("first\nsecond\nlast")
      i1 = SourceInterval.new(s, 3, 4)

      assert(i1.from_location.line_number == 0)
      assert(i1.from_location.column_number == 3)
      assert(i1.to_location.line_number == 1)
      assert(i1.to_location.column_number == 1)
      assert(i1.content == "st\ns")
      assert(i1.content.size == i1.length)
    end

    def test_empty_lines
      s = Source.new("\n\n\n")
      i1 = SourceInterval.new(s, 1, 2)

      assert(i1.from_location.line_number == 2)
      assert(i1.from_location.column_number == 0)
      assert(i1.to_location.line_number == 3)
      assert(i1.to_location.column_number == 0)
      assert(i1.content == "\n\n")
      assert(i1.content.size == i1.length)
    end

  end
end
