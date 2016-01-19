require "../spec_helper"

module ParseStateTests
  class ParseStateTest < Minitest::Test
    def test_inspect
      assert Syntaks::ParseState.new(Syntaks::Source.new("")).inspect != "" # FIXME
    end
  end
end
