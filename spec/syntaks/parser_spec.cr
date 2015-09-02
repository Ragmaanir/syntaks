require "../spec_helper"

module SyntaksSpec_Parser

  include Syntaks
  include Syntaks::Parsers

  class TestParser

    class Root < InnerNode
      def initialize(@args : Arguments)
        @children = [@args]
      end
    end

    class Arguments < InnerNode
      def initialize(@children : Array(Syntaks::Node))
      end
    end

    class Argument < InnerNode
      def initialize(@lit : Literal)
        @children = [@lit]
      end
    end

    class Literal < TerminalNode
      private def internal_data
        @interval.to_s
      end
    end

    def root
      SequenceParser(Root).new([StringParser.new("["), args, StringParser.new("]")]) do |args|
        Root.new(args[1] as Arguments)
      end
    end

    def args
      ListParser(Arguments).new(arg, StringParser.new(","))
    end

    def arg
      SequenceParser(Argument).new([literal]) do |args|
        Argument.new(args[0] as Literal)
      end
    end

    def literal
      TokenParser(Literal).new(/[1-9][0-9]*/)
    end
  end

  describe Syntaks::Parser do
    it "" do
      parser = TestParser.new.root

      source = Syntaks::Source.new("[190,500,1337]")
      state = Syntaks::ParseState.new(source)

      res = parser.call(state)
      assert res.success?
    end

    it "" do
      parser = TestParser.new.root

      source = Syntaks::Source.new("[1,]")
      state = Syntaks::ParseState.new(source)

      assert !parser.call(state).success?
    end

    it "" do
      parser = TestParser.new.root

      source = Syntaks::Source.new("[1,,]")
      state = Syntaks::ParseState.new(source)

      assert !parser.call(state).success?
    end
  end

end

module SyntaksSpec_RecursiveParsers
  include Syntaks
  include Syntaks::Parsers

  class AddExp < InnerNode
  end

  class AddExpTail < InnerNode
  end

  class AddExpElem < InnerNode
  end

  class TerminalAddExp < InnerNode
  end

  class Literal < TerminalNode
  end

  class Operator < TerminalNode
  end

  def self.exp
    add_exp
  end

  def self.add_exp
    @@add_exp ||= ParserReference.new do
      SequenceParser(AddExp).new([
        terminal_add_exp,
        ListParser(AddExpTail).new(
          SequenceParser(AddExpElem).new([
            TokenParser(Operator).new(/[+-]/),
            terminal_add_exp
          ])
        )
      ])
    end
  end

  def self.terminal_add_exp
    @@terminal_add_exp ||= ParserReference.new do
      AlternativeParser.new([par_exp, literal])
    end
  end

  def self.par_exp
    @@par_exp ||= ParserReference.new do
      SequenceParser(AddExp).new([
        StringParser.new("("),
        add_exp,
        StringParser.new(")")
      ])
    end
  end

  def self.literal
    TokenParser(Literal).new(/[1-9][0-9]*/)
  end

  describe Syntaks::Parser do
    it "" do
      parser = exp

      source = Syntaks::Source.new("1+234")
      state = Syntaks::ParseState.new(source)

      res = parser.call(state)
      assert res.success?
    end

    it "" do
      parser = exp

      source = Syntaks::Source.new("1+234+(1234-55)")
      state = Syntaks::ParseState.new(source)

      res = parser.call(state)
      assert res.success?
    end

    pending "" do
      parser = exp

      source = Syntaks::Source.new("1+234+(1234-)")
      state = Syntaks::ParseState.new(source)

      res = parser.call(state)
      assert !res.success?
    end
  end
end
