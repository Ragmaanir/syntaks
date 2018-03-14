require "../spec_helper"

describe Syntaks::EBNF::AbstractComponent do
  include EBNF

  rule(a, Token, "a")
  rule(b, Token, "b")
  rule(c, Token, "c")
  rule(d, Token, "d")

  test "sequence" do
    r = build_ebnf(a >> b >> c)
    assert Seq.build(Seq.build(a, b), c) == r
  end

  test "optional" do
    r = build_ebnf(a >> b >> ~c)
    assert Seq.build(Seq.build(a, b), Opt.new(c)) == r
  end

  test "alternatives" do
    r = build_ebnf(a | b | c)
    assert Alt.build(Alt.build(a, b), c) == r
  end

  test "repetition" do
    r = build_ebnf({a >> b})
    assert Rep.new(Seq.build(a, b)) == r

    r = build_ebnf({a >> b} >> c)
    assert Seq.build(Rep.new(Seq.build(a, b)), c) == r
  end

  test "not predicate" do
    r = build_ebnf(-(a >> b))
    assert NotPredicate.new(Seq.build(a, b)) == r
  end

  test "mixture" do
    r = build_ebnf((a >> b) | ~(c >> d))
    assert Alt.build(Seq.build(a, b), Opt.new(Seq.build(c, d))) == r
  end

  test "terminals" do
    r = build_ebnf(a >> "test")
    assert Seq.build(a, Terminal.build("test")) == r
  end

  test "to_s" do
    ebnf = build_ebnf({a >> b})
    assert ebnf.to_s == "{a >> b}"

    ebnf = build_ebnf(a >> b >> c)
    assert ebnf.to_s == "a >> b >> c"

    ebnf = build_ebnf(a >> b | c)
    # assert ebnf.to_s == "(a >> b) | c" # FIXME: parentheses

    ebnf = build_ebnf(a >> ~b >> ~(c | d))
    assert ebnf.to_s == "a >> ~b >> ~(c | d)"

    ebnf = build_ebnf(a >> "test" >> /test2/)
    assert ebnf.to_s == "a >> \"test\" >> /test2/"
  end
end

describe Syntaks::EBNF do
  include EBNF

  test "nonterminal equality" do
    a = ->{ Terminal.build("a").as_component }
    b = ->{ Terminal.build("b").as_component }

    assert NonTerminal.build("a", a) == NonTerminal.build("a", a)
    assert NonTerminal.build("a", a) != NonTerminal.build("b", b)

    assert NonTerminal.build("a", a) == NonTerminal.build("a", b)
    assert NonTerminal.build("a", a) != NonTerminal.build("b", a)
  end

  class P < Syntaks::Parser
    include EBNF

    rule(root, {Token, Array(Token)}, "a" >> {"b"})
  end

  test "compile error" do
    assert P.new.call("ab").is_a?(Success)
  end

  test "parse log" do
    source = Source.new("abbbb")
    state = State.new(source, 0)
    ctx = LoggingContext.new(ParseLog.new(source))
    s = P.new.call(state, ctx).as Success
    ctx.parse_log.to_s
    assert s.end_state.at == source.size
  end

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

end
