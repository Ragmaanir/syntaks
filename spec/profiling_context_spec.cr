require "./spec_helper"

describe Syntaks::EBNF::ProfilingContext do
  include Syntaks::EBNF

  alias Parser = ExampleParsers::MethodParser

  SOURCE = <<-SRC
    def a1
      x1 = some_var
    end

    def b1
      if xyz
        puts()
      end
    end
  SRC

  test "profile" do
    ctx = ProfilingContext.new
    res = Parser.new.call(SOURCE, ctx).as(Success)
    assert res.value.size == 2
    assert(/statements.*:\s+3/ === ctx.to_s)
    assert(/"if" >> _s.*:\s+1/ === ctx.to_s)
  end
end
