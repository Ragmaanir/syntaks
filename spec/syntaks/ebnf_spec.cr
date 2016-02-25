require "../spec_helper"

module EBNFTests
  class EBNFMacroTest < Minitest::Test
    include EBNF

    def test_nonterminal_equality
      a = ->{ Terminal.new("a") }
      b = ->{ Terminal.new("b") }
      assert NonTerminal.new("a", a) == NonTerminal.new("a", a)
      assert NonTerminal.new("a", a) != NonTerminal.new("b", b)

      assert NonTerminal.new("a", a) == NonTerminal.new("a", b)
      assert NonTerminal.new("a", a) != NonTerminal.new("b", a)
    end

    def a
      @a ||= NonTerminal.new("a", ->{ Terminal.new("a") })
    end

    def b
      @b ||= NonTerminal.new("b", ->{ Terminal.new("b") })
    end

    def c
      @c ||= NonTerminal.new("c", ->{ Terminal.new("c") })
    end

    def d
      @d ||= NonTerminal.new("d", ->{ Terminal.new("d") })
    end

    def test_sequence
      assert_equal Seq.build(Seq.build(a, b), c), rule(:xyz, a >> b >> c)
    end

    def test_optional
      assert_equal Seq.build(Seq.build(a, b), Opt.new(c)), rule(:abc, a >> b >> ~c)
    end

    def test_alternatives
      assert_equal Alt.build(Alt.build(a, b), c), rule(:abc, a | b | c)
    end

    def test_repetition
      assert_equal Rep.new(Seq.build(a, b)), rule(:abc, {a >> b})
    end

    def test_mixture
      assert_equal Alt.build(Seq.build(a, b), Opt.new(Seq.build(c, d))), rule(:abc, (a >> b) | ~(c >> d))
    end

    # Version A
    # sequence: a >> b >> c
    # alternatives: a | b | c
    # option: [a] or ~a
    # repetition: {a}

    # Version B
    # sequence: [a, b, c]
    # alternatives: a | b | c
    # option: ~a
    # repetition: {a}
  end
end
