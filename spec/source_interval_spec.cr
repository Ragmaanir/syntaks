require "./spec_helper"

describe Syntaks::SourceInterval do
  test "nonempty lines" do
    s = Source.new("first\nsecond\nlast")
    i1 = SourceInterval.new(s, 3, 4)

    assert(i1.from_location.line_number == 1)
    assert(i1.from_location.column_number == 4)
    assert(i1.to_location.line_number == 2)
    assert(i1.to_location.column_number == 1)
    assert(i1.content == "st\ns")
    assert(i1.content.size == i1.length)
  end

  test "empty lines" do
    s = Source.new("\n\n\n")
    i1 = SourceInterval.new(s, 1, 2)

    assert(i1.from_location.line_number == 2)
    assert(i1.from_location.column_number == 1)
    assert(i1.to_location.line_number == 3)
    assert(i1.to_location.column_number == 1)
    assert(i1.content == "\n\n")
    assert(i1.content.size == i1.length)
  end
end
