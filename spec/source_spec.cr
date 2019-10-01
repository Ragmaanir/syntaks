require "./spec_helper"

describe Syntaks::Source do
  test "size" do
    s = Source.new("aaaaa")
    assert s.size == 5
  end

  test "newline_indices" do
    s = Source.new("")
    assert s.newline_indices == [] of Int32

    s = Source.new("aaaa")
    assert s.newline_indices == [] of Int32

    s = Source.new("\n")
    assert s.newline_indices == [0] of Int32

    s = Source.new("ä\n\ntest\n")
    assert s.newline_indices == [2, 3, 8] of Int32
  end

  test "find_leading_newline_idx_at_byte" do
    s = Source.new("")
    assert s.find_leading_newline_idx_at_byte(0) == nil

    s = Source.new("a")
    assert s.find_leading_newline_idx_at_byte(0) == nil
    assert s.find_leading_newline_idx_at_byte(1) == nil

    s = Source.new("\n")
    assert s.find_leading_newline_idx_at_byte(0) == nil
    assert s.find_leading_newline_idx_at_byte(1) == 0

    s = Source.new("a\n")
    assert s.find_leading_newline_idx_at_byte(0) == nil
    assert s.find_leading_newline_idx_at_byte(1) == nil
    assert s.find_leading_newline_idx_at_byte(2) == 0
  end

  # -------------------- line_number_at_byte
  test "line_number_at_byte on empty source" do
    s = Source.new("")
    assert s.line_number_at_byte(0) == 0
  end

  test "line_number_at_byte on source with no newline" do
    s = Source.new("a")
    assert s.line_number_at_byte(0) == 0
    # assert s.line_number_at_byte(1) == 0 # raise instead?
  end

  test "line_number_at_byte with no newline at end" do
    s = Source.new("\na")

    assert s.line_number_at_byte(0) == 0
    assert s.line_number_at_byte(1) == 1
    # assert s.line_number_at_byte(2) == 1 # raise instead?
  end

  test "line_number_at_byte on source with just newlines" do
    s = Source.new("\n\n\n")
    assert s.line_number_at_byte(0) == 0
    assert s.line_number_at_byte(1) == 1
    assert s.line_number_at_byte(2) == 2
    # assert s.line_number_at_byte(3) == 3 # raise instead?
  end

  test "line_number_at_byte" do
    s = Source.new("class Foo\npass\nend\n")
    assert s.line_number_at_byte(0) == 0
    assert s.line_number_at_byte(8) == 0
    assert s.line_number_at_byte(9) == 0
    assert s.line_number_at_byte(10) == 1

    assert s.line_number_at_byte(13) == 1
    assert s.line_number_at_byte(14) == 1
    assert s.line_number_at_byte(15) == 2
  end

  # -------------------- column_number_at_byte
  test "column_number_at_byte on empty source" do
    s = Source.new("")
    assert s.column_number_at_byte(0) == 0
  end

  test "column_number_at_byte on source with no newline" do
    s = Source.new("a")
    assert s.column_number_at_byte(0) == 0
    # assert s.column_number_at_byte(1) == 0 # raise instead?
  end

  test "column_number_at_byte with no newline at end" do
    s = Source.new("\na")

    assert s.column_number_at_byte(0) == 0
    assert s.column_number_at_byte(1) == 0
    # assert s.column_number_at_byte(2) == 1 # raise instead?
  end

  test "column_number_at_byte on source with just newlines" do
    s = Source.new("\n\n\n")
    assert s.column_number_at_byte(0) == 0
    assert s.column_number_at_byte(1) == 0
    assert s.column_number_at_byte(2) == 0
    # assert s.column_number_at_byte(3) == 3 # raise instead?
  end

  test "column_number_at_byte" do
    s = Source.new("class Foo\npass\nend\n")
    assert s.column_number_at_byte(0) == 0
    assert s.column_number_at_byte(8) == 8
    assert s.column_number_at_byte(9) == 9
    assert s.column_number_at_byte(10) == 0

    assert s.column_number_at_byte(13) == 3
    assert s.column_number_at_byte(14) == 4
    assert s.column_number_at_byte(15) == 0
  end

  test "line_start_at_byte" do
    # s = Source.new("")

    # assert s.line_start_at_byte(0) == 0
    # assert s.line_start_at_byte(1) == 0

    s = Source.new("\n")

    assert s.line_start_at_byte(0) == 0
    # assert s.line_start_at_byte(1) == 1

    s = Source.new("a\n")

    assert s.line_start_at_byte(0) == 0
    assert s.line_start_at_byte(1) == 0
    # assert s.line_start_at_byte(2) == 2

    s = Source.new("\na")

    assert s.line_start_at_byte(0) == 0
    assert s.line_start_at_byte(1) == 1
    # assert s.line_start_at_byte(2) == 1

    s = Source.new("\n\n\n")

    assert s.line_start_at_byte(0) == 0
    assert s.line_start_at_byte(1) == 1
    assert s.line_start_at_byte(2) == 2
    # assert s.line_start_at_byte(3) == 3
  end

  test "line_end_at_byte on empty source" do
    s = Source.new("")

    assert_raises(IndexError) { s.line_end_at_byte(0) }
  end

  test "line_end_at_byte" do
    s = Source.new("\n")

    assert s.line_end_at_byte(0) == 0
    # assert s.line_end_at_byte(1) == 1

    s = Source.new("a\n")

    assert s.line_end_at_byte(0) == 1
    assert s.line_end_at_byte(1) == 1
    # assert s.line_end_at_byte(2) == 2

    s = Source.new("\na")

    assert s.line_end_at_byte(0) == 0
    assert s.line_end_at_byte(1) == 1
    # assert s.line_end_at_byte(2) == 1

    s = Source.new("\n\n\n")

    assert s.line_end_at_byte(0) == 0
    assert s.line_end_at_byte(1) == 1
    assert s.line_end_at_byte(2) == 2
    # assert s.line_end_at_byte(3) == 3
  end
end
