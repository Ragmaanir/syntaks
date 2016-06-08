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

    rules do
      a = "a"
      b = "b"
      c = "c"
      d = "d"
    end

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
      #assert ebnf.to_s == "(a >> b) | c" # FIXME: parentheses

      ebnf = build_ebnf(a >> ~b >> ~(c | d))
      assert ebnf.to_s == "a >> ~b >> ~(c | d)"

      ebnf = build_ebnf(a >> "test" >> /test2/)
      assert ebnf.to_s == "a >> \"test\" >> /test2/"
    end

    rule(x = "int " >> /[1-9][0-9]+/) do |v|
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
      assert s.end_state.at == 1

      s = r.call(State.new(Source.new("b"), 0)) as Success
      assert s.end_state.at == 0
    end

    def test_parse_log
      source = Source.new("ababababa")
      state = State.new(source, 0)
      ctx = LoggingContext.new(ParseLog.new(source))
      r = build_ebnf(a >> {b >> a})
      s = r.call(state, ctx) as Success
      assert s.end_state.at == source.size
    end

  end

  class ExampleParserTest < Minitest::Test
    class Parser < Syntaks::Parser
      rules do
        root      = call
        call      = "method" >> /\s+/ >> id >> param_list
        param_list = "(" >> params >> ")"
        params    = param >> {"," >> param}
        param     = int_lit | name_lit
        int_lit   = /\d+/
        name_lit  = /\w+/
        id        = /\w+/
      end

      # {
      #   Syntaks::EBNF::NonTerminal(Syntaks::Token, Syntaks::Token),
      #   {
      #     Syntaks::Token:Class,
      #     Syntaks::EBNF::NonTerminal(Syntaks::Token, Syntaks::Token):Class
      #   }
      # }

      def xxx
        p build_ebnf_type("a" | "b")
        p build_ebnf_type("a" >> "b")
        p build_ebnf_type("a" >> "b" >> "c")
        p build_ebnf_type("a" | ("b" >> "c"))
        p build_ebnf_type("method" >> params)
        argument = {"1", "2"}
        p unpack_nested_tuples("a" >> "b")
        argument = {Tuple.new("1", "2"), "3"}
        p unpack_nested_tuples("a" >> "b" >> "c")
        p xyz(test)
      end
    end

    def test_acceptance
      Parser.new.xxx
      assert Parser.new.call("method test(banana,1337,9001)").is_a?(Success)
      assert Parser.new.call("method a(1)").is_a?(Success)

      assert Parser.new.call("method test()").is_a?(Failure)
    end

  end
end
