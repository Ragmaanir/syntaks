require "./spec_helper"

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
