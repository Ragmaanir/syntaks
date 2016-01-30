require "../spec_helper"

module SourceLocationTests
  class SourceLocationTest < Minitest::Test

    def test_nonempty_lines
      s = Source.new("first\nsecond\nlast")
      l1 = SourceLocation.new(s, 3)

      assert(l1.line_number == 0)
      assert(l1.column_number == 3)
      assert(l1.line == "first\n")
    end

    def test_empty_lines
      s = Source.new("\n\n\n")
      l1 = SourceLocation.new(s, 1)

      assert(l1.line_number == 2)
      assert(l1.column_number == 0)
      assert(l1.line_start == 1)
      assert(l1.line_end == 1)
      assert(l1.line == "\n")
    end

  end
end
