require "../spec_helper"

module ParseStateTests
  class ParseStateTest < Minitest::Test
    def test_inspect
      p Syntaks::ParseState.new(Syntaks::Source.new(""))
    end
  end
end
