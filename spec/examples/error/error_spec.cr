describe ListExample do
  include Syntaks::EBNF

  {{`cat spec/examples/error/parser.cr`}}

  test "error message" do
    {{`cat spec/examples/error/example.cr`}}
  end
end
