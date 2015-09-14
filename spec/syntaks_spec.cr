require "./spec_helper"

module DjaevlSyntaks
  class DjaevlTest < Minitest::Test

    class DjaevlParser < Syntaks::FullParser
      include Syntaks::Parsers
      include Syntaks::DSL

      class Token
        getter :value

        def initialize(@value : String)
        end

        def ==(other : Token)
          @value == other.value
        end

        def inspect(io)
          io << "Token(#{@value.inspect})"
        end
      end

      def root
        class_def
      end

      def class_def
        mseq(str("class"), space, id, class_body) do |_, _, name, body|
          {name, body}
        end
      end

      def class_body
        mseq(nl, instance_var_decl, nl, str("endclass")) do |_, var_decl, _, _|
          [var_decl]
        end
      end

      def instance_var_decl
        mseq(str("attribute"), space, id) do |_, _, name|
          name
        end
      end

      def id
        token(/[a-zA-Z_][a-zA-Z_0-9]*/, Token)
      end

      def space
        str(/\s+/)
      end

      def nl
        str(/\s*[\n;]\s*/)
      end
    end

    def test_full_match
      assert DjaevlParser.new.call("class User \n attribute age \n endclass").full_match?
    end

    def test_ast
      res = DjaevlParser.new.call("class User \n attribute age \n endclass") as Syntaks::ParseSuccess
      assert res.value == {
        DjaevlParser::Token.new("User"),
        [DjaevlParser::Token.new("age")]
      }
    end

  end
end
