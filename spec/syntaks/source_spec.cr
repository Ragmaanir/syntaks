require "../spec_helper"

describe Syntaks::Source do
  test "size" do
    s = Source.new("aaaaa")
    assert s.size == 5
  end
end
