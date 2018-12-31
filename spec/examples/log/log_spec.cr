describe LogExample do
  include Syntaks::EBNF

  {{`cat spec/example_parsers.cr`}}

  test "generates a parse-log" do
    {{`cat spec/examples/log/example.cr`}}
  end
end
