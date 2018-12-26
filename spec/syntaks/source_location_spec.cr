require "../spec_helper"

describe Syntaks::SourceLocation do
  test "nonempty lines" do
    s = Source.new("first\nsecond\nlast")
    l = SourceLocation.new(s, 3)

    assert(l.line_number == 1)
    assert(l.column_number == 4)
    assert(l.line_start == 0)
    assert(l.line_end == 5)
    assert(l.line == "first\n")

    l = SourceLocation.new(s, 5)

    assert(l.line_number == 1)
    assert(l.column_number == 6)
    assert(l.line == "first\n")

    l = SourceLocation.new(s, 6)

    assert(l.line_number == 2)
    assert(l.column_number == 1)
    assert(l.line == "second\n")
  end

  test "empty lines" do
    s = Source.new("\n\n\n")
    l = SourceLocation.new(s, 1)

    assert(l.line_number == 2)
    assert(l.column_number == 1)
    assert(l.line_start == 1)
    assert(l.line_end == 1)
    assert(l.line == "\n")
  end
end

# module SourceLocationTests
#   class SourceLocationTest < Minitest::Test

#     def test_nonempty_lines
#       s = Source.new("first\nsecond\nlast")
#       l1 = SourceLocation.new(s, 3)

#       assert(l1.line_number == 0)
#       assert(l1.column_number == 3)
#       assert(l1.line == "first\n")
#     end

#     def test_empty_lines
#       s = Source.new("\n\n\n")
#       l1 = SourceLocation.new(s, 1)

#       assert(l1.line_number == 2)
#       assert(l1.column_number == 0)
#       assert(l1.line_start == 1)
#       assert(l1.line_end == 1)
#       assert(l1.line == "\n")
#     end

#   end
# end
