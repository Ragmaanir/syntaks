require "../spec_helper"

describe Syntaks::EBNF do
  include EBNF

  test "nonterminal_equality" do
    a = ->{ Terminal.build("a").as_component }
    b = ->{ Terminal.build("b").as_component }

    assert NonTerminal.build("a", a) == NonTerminal.build("a", a)
    assert NonTerminal.build("a", a) != NonTerminal.build("b", b)

    assert NonTerminal.build("a", a) == NonTerminal.build("a", b)
    assert NonTerminal.build("a", a) != NonTerminal.build("b", a)
  end

  rules do
    a = "a"
    b = "b"
    c = "c"
    d = "d"
  end

  # rule(:a, "a")
  # rule(:b, "b")
  # rule(:c, "c")
  # rule(:d, "d")

  class P < Syntaks::Parser
    include EBNF

    # getter x : NonTerminal(String)
    @x : NonTerminal(String) | Nil

    def x
      @x ||= NonTerminal.build("x", ->{ Terminal.new("x", ->(t : Token) { "x" }) })
    end

    def root
      x
    end
  end

  test "compile error" do
    p = P.new
    assert P.new.call("x").is_a?(Success)
  end

  # test "sequence" do
  #   assert_equal Seq.build(Seq.build(a, b), c), build_ebnf(a >> b >> c)
  # end

  # test "optional" do
  #   assert_equal Seq.build(Seq.build(a, b), Opt.new(c)), build_ebnf(a >> b >> ~c)
  # end

  # test "alternatives" do
  #   assert_equal Alt.build(Alt.build(a, b), c), build_ebnf(a | b | c)
  # end

  # test "repetition" do
  #   assert_equal Rep.new(Seq.build(a, b)), build_ebnf({a >> b})
  # end

  # test "mixture" do
  #   assert_equal Alt.build(Seq.build(a, b), Opt.new(Seq.build(c, d))), build_ebnf((a >> b) | ~(c >> d))
  # end

  # test "terminals" do
  #   assert_equal Seq.build(a, Terminal.build("test")), build_ebnf(a >> "test")
  # end

  # test "to_s" do
  #   ebnf = build_ebnf({a >> b})
  #   assert ebnf.to_s == "{a >> b}"

  #   ebnf = build_ebnf(a >> b >> c)
  #   assert ebnf.to_s == "a >> b >> c"

  #   ebnf = build_ebnf(a >> b | c)
  #   # assert ebnf.to_s == "(a >> b) | c" # FIXME: parentheses

  #   ebnf = build_ebnf(a >> ~b >> ~(c | d))
  #   assert ebnf.to_s == "a >> ~b >> ~(c | d)"

  #   ebnf = build_ebnf(a >> "test" >> /test2/)
  #   assert ebnf.to_s == "a >> \"test\" >> /test2/"
  # end

  # rule(x = "int " >> /[1-9][0-9]+/) do |v|
  #   v[1].content.to_i
  # end

  # test "actions" do
  #   r = x.call(State.new(Source.new("int 110"), 0)).as Success
  #   assert r.value == 110
  # end

  # test "parsing" do
  #   state = State.new(Source.new("aaaaa"), 0)
  #   r = build_ebnf(a >> a >> a)
  #   s = r.call(state).as Success

  #   r = build_ebnf(a >> {a >> a})
  #   s = r.call(state).as Success

  #   r = build_ebnf(b | a)
  #   s = r.call(state).as Success
  # end

  # test "optional" do
  #   r = build_ebnf(~a)

  #   s = r.call(State.new(Source.new("a"), 0)).as Success
  #   assert s.end_state.at == 1

  #   s = r.call(State.new(Source.new("b"), 0)).as Success
  #   assert s.end_state.at == 0
  # end

  # test "parse_log" do
  #   source = Source.new("ababababa")
  #   state = State.new(source, 0)
  #   ctx = LoggingContext.new(ParseLog.new(source))
  #   r = build_ebnf(a >> {b >> a})
  #   s = r.call(state, ctx).as Success
  #   assert s.end_state.at == source.size
  # end
end

# describe Syntaks::Parser do
#   class Parser < Syntaks::Parser
#     rules do
#       root = call
#       call = "method" >> /\s+/ >> id >> param_list
#       param_list = "(" >> params >> ")"
#       params = param >> {"," >> param}
#       param = int_lit | name_lit
#       int_lit = /\d+/
#       name_lit = /\w+/
#       id = /\w+/
#     end

#     # {
#     #   Syntaks::EBNF::NonTerminal(Syntaks::Token, Syntaks::Token),
#     #   {
#     #     Syntaks::Token:Class,
#     #     Syntaks::EBNF::NonTerminal(Syntaks::Token, Syntaks::Token):Class
#     #   }
#     # }

#     def xxx
#       p build_ebnf_type("a" | "b")
#       p build_ebnf_type("a" >> "b")
#       p build_ebnf_type("a" >> "b" >> "c")
#       p build_ebnf_type("a" | ("b" >> "c"))
#       p build_ebnf_type("method" >> params)
#       argument = {"1", "2"}
#       p unpack_nested_tuples("a" >> "b")
#       argument = {Tuple.new("1", "2"), "3"}
#       p unpack_nested_tuples("a" >> "b" >> "c")
#       p xyz(test)
#     end
#   end

#   test "acceptance" do
#     Parser.new.xxx
#     assert Parser.new.call("method test(banana,1337,9001)").is_a?(Success)
#     assert Parser.new.call("method a(1)").is_a?(Success)

#     assert Parser.new.call("method test()").is_a?(Failure)
#   end
# end
