require "../spec_helper"

module EBNFTests
  class EBNFMacroTest < Minitest::Test
    include EBNF

    def test_nonterminal_equality
      assert NonTerminal.new("a") == NonTerminal.new("a")
      assert NonTerminal.new("a") != NonTerminal.new("b")
    end

    def test_sequence
      na, nb, nc = {:a, :b, :c}.map{ |n| NonTerminal.new(n.to_s) }

      assert_equal Seq.new([Seq.new([na, nb]), nc]), rule(:xyz, a >> b >> c)
    end

    def test_optional
      na, nb, nc = {:a, :b, :c}.map{ |n| NonTerminal.new(n.to_s) }
      assert_equal Seq.new([Seq.new([na, nb]), Opt.new(nc)]), rule(:abc, a >> b >> ~c)
    end

    def test_alternatives
      na, nb, nc = {:a, :b, :c}.map{ |n| NonTerminal.new(n.to_s) }
      assert_equal Alt.new([Alt.new([na, nb]), nc]), rule(:abc, a | b | c)
    end

    def test_repetition
      na, nb = {:a, :b}.map{ |n| NonTerminal.new(n.to_s) }
      assert_equal Rep.new(Seq.new([na, nb])), rule(:abc, {a >> b})
    end

    def test_mixture
      na, nb, nc, nd = {:a, :b, :c, :d}.map{ |n| NonTerminal.new(n.to_s) }
      assert_equal Alt.new([Seq.new([na, nb]), Opt.new(Seq.new([nc, nd]))]), rule(:abc, (a >> b) | ~(c >> d))
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
