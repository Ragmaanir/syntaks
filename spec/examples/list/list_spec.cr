describe ListExample do
  include Syntaks::EBNF

  {{`cat spec/examples/list/parser.cr`}}

  test "parses comma separated list" do
    {{`cat spec/examples/list/example.cr`}}
  end
end
