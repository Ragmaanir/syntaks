require "./spec_helper"

describe Syntaks do
  # TODO: Write tests

  it "works" do
    parser = Syntaks::ParserBuilder.new do
    end.root

    source = Syntaks::Source.new("[190,500]")
    state = Syntaks::ParseState.new(source)
    res = parser.call(state)
    assert res.success?
  end
end
