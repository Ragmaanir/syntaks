require "../../spec_helper"

describe Syntaks::Benchmark do
  include Syntaks::EBNF

  alias Parser = ExampleParsers::MethodParser

  SOURCE = 1000.times.map do |i|
    <<-SRC
      def a#{i}
        x#{i} = some_var
      end

      def b#{i}
        if xyz
          puts()
        end
      end
    SRC
  end.join

  test "parse complex example" do
    # ctx = ProfilingContext.new
    ctx = EmptyContext.new
    res = Parser.new.call(SOURCE, ctx).as(Success)
    assert res.value.size == 2000
  end
end
