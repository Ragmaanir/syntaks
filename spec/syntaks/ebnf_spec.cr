require "../spec_helper"

module EBNFTests
  class EBNFMacroTest < Minitest::Test
    include EBNF

    def test_nonterminal_equality
      a = ->{ Terminal.build("a") }
      b = ->{ Terminal.build("b") }
      assert NonTerminal.build("a", a) == NonTerminal.build("a", a)
      assert NonTerminal.build("a", a) != NonTerminal.build("b", b)

      assert NonTerminal.build("a", a) == NonTerminal.build("a", b)
      assert NonTerminal.build("a", a) != NonTerminal.build("b", a)
    end

    rule(:a, "a")
    rule(:b, "b")
    rule(:c, "c")
    rule(:d, "d")

    def test_sequence
      assert_equal Seq.build(Seq.build(a, b), c), build_ebnf(a >> b >> c)
    end

    def test_optional
      assert_equal Seq.build(Seq.build(a, b), Opt.new(c)), build_ebnf(a >> b >> ~c)
    end

    def test_alternatives
      assert_equal Alt.build(Alt.build(a, b), c), build_ebnf(a | b | c)
    end

    def test_repetition
      assert_equal Rep.new(Seq.build(a, b)), build_ebnf({a >> b})
    end

    def test_mixture
      assert_equal Alt.build(Seq.build(a, b), Opt.new(Seq.build(c, d))), build_ebnf((a >> b) | ~(c >> d))
    end

    def test_terminals
      assert_equal Seq.build(a, Terminal.build("test")), build_ebnf(a >> "test")
    end

    def test_to_s
      ebnf = build_ebnf({a >> b})
      assert ebnf.to_s == "{a >> b}"

      ebnf = build_ebnf(a >> b >> c)
      assert ebnf.to_s == "a >> b >> c"

      ebnf = build_ebnf(a >> b | c)
      #assert ebnf.to_s == "(a >> b) | c" # FIXME

      ebnf = build_ebnf(a >> ~b >> ~(c | d))
      assert ebnf.to_s == "a >> ~b >> ~(c | d)"

      ebnf = build_ebnf(a >> "test" >> /test2/)
      assert ebnf.to_s == "a >> \"test\" >> /test2/"
    end

    rule(:x, "int " >> /[1-9][0-9]+/) do |v|
      v[1].content.to_i
    end

    def test_actions
      r = x.call(State.new(Source.new("int 110"), 0)) as Success
      assert r.value == 110
    end

    def test_parsing
      state = State.new(Source.new("aaaaa"), 0)
      r = build_ebnf(a >> a >> a)
      s = r.call(state) as Success

      r = build_ebnf(a >> {a >> a})
      s = r.call(state) as Success

      r = build_ebnf(b | a)
      s = r.call(state) as Success
    end

    def test_optional
      r = build_ebnf(~a)

      s = r.call(State.new(Source.new("a"), 0)) as Success
      assert s.success?
      assert s.end_state.at == 1

      s = r.call(State.new(Source.new("b"), 0)) as Success
      assert s.success?
      assert s.end_state.at == 0
    end

    def test_parse_log
      source = Source.new("ababa")
      state = State.new(source, 0)
      ctx = LoggingContext.new(ParseLog.new(source))
      r = build_ebnf(a >> {b >> a})
      s = r.call(state, ctx) as Success
    end

    def experiments
      build_ebnf(a > b) # disable backtracking
      build_ebnf(a > b > c > !newline) # sync token
    end

  end
end
