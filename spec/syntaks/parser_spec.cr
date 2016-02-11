require "../spec_helper"

module ParserTests

  class ListParserAcceptanceTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks
      include Syntaks::Parsers

      class Root < InnerNode
        def initialize(@args : Arguments)
          @children = [@args]
        end
      end

      class Arguments < InnerNode
        def initialize(@children : Array(Syntaks::Node))
        end
      end

      class Literal < TerminalNode
        def initialize(@value : String)
        end

        def internal_data
          @value
        end
      end

      def root
        SequenceParser.new(
          TokenParser.build("["),
          SequenceParser.new(
            args,
            TokenParser.build("]")
          ),
         ->(args : {Token, {Array(Literal), Token}}){ Root.new(Arguments.new(args[1][0])) }
        )
      end

      def args
        ListParser(Literal).new(literal, TokenParser.build(","))
      end

      def literal
        TokenParser(Literal).build(/[1-9][0-9]*/, ->(s : Token){ Literal.new(s.content) })
      end
    end


    def test_full_match
      assert TestParser.new.call("[190,500,1337]").full_match?
      r = TestParser.new.call("[190,500,1337]") as Syntaks::ParseSuccess
      assert r.value.is_a?(TestParser::Root)
    end

    def test_no_match
      assert !TestParser.new.call("[1,]").success?
      assert !TestParser.new.call("[1,,]").success?
    end

  end

  class RecursiveDefinitionTest < Minitest::Test
    class TestParser < Syntaks::FullParser
      include Syntaks
      include Syntaks::Parsers

      class AddExp < InnerNode
        def initialize(@left : Node, @right = nil : Array({Operator, Node})?)
        end
      end

      class AddExpTail < InnerNode
      end

      class AddExpElem < InnerNode
      end

      class TerminalAddExp < InnerNode
      end

      class Literal < TerminalNode
        def initialize(@value)
        end

        def internal_data
          @value
        end
      end

      class Operator < TerminalNode
        def initialize(@name)
        end

        def internal_data
          @name
        end
      end

      def root
        add_exp
      end

      def add_exp
        @add_exp ||= ParserReference.build "add_exp", ->{
          SequenceParser.new(
            terminal_add_exp,
            ListParser({Operator, AddExp}).new(
              SequenceParser.new(
                TokenParser(Operator).new(/[+-]/, ->(s : Token){ Operator.new(s.content) }),
                terminal_add_exp
              )
            ),
            ->(args : {AddExp, Array({Operator, AddExp})}){ AddExp.new(args[0], args[1]) }
          )
        }
      end

      def terminal_add_exp
        @terminal_add_exp ||= ParserReference(AddExp | Literal).build "terminal_add_exp", ->{
          AlternativeParser.build(par_exp, literal)
        }
      end

      def par_exp
        @par_exp ||= ParserReference(AddExp).build "par_exp", ->{
          SequenceParser(Nil, {AddExp, Nil}, AddExp).new(
            StringParser.new("("),
            SequenceParser.new(
              add_exp,
              StringParser.new(")")
            ),
            ->(args : {Nil, {AddExp, Nil}}){ args[1][0] }
          )
        }
      end

      def literal
        TokenParser.new(/[1-9][0-9]*/, ->(s : Token){ AddExp.new(Literal.new(s.content)) })
      end
    end

    def test_full_match
      assert TestParser.new.call("1+234").full_match?
      assert TestParser.new.call("1+234+(1234-55)").full_match?
    end

    def test_no_full_match
      res = TestParser.new.call("1+234+(1234-)")
      assert !res.full_match?
    end
  end
end
