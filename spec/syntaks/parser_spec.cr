require "../spec_helper"

module ListParserSpec

  class ListParser
    include Syntaks

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
      def initialize(@state, @interval)
      end

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
      parser = ListParser.new.root

      source = Syntaks::Source.new("[190,500]")
      state = Syntaks::ParseState.new(source)
      res = parser.call(state) as Syntaks::ParseSuccess

      puts res.node.to_s(0)
    end
  end

end
