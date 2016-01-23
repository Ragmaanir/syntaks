require "./spec_helper"

module DjaevlSyntaks
  class DjaevlTest < Minitest::Test

    class DjaevlParser < Syntaks::FullParser
      include Syntaks::Parsers
      include Syntaks::DSL

      class Token
        getter value

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

      rule(:class_def) do
        sequence(opt_space, str("class"), space, id, nl, class_body) do |_, _, _, name, _, body|
          {name, body}
        end
      end

      rule(:class_body) do
        sequence(member_defs, str("endclass")) do |members, _|
          members
        end
      end

      rule(:member_defs) do
        ListParser.new(member_def, nl)
      end

      rule(:member_def) do
        #alternatives(method_def)
        method_def
      end

      rule(:method_def) do
        sequence(opt_space, str("method"), space, id, nl, method_body, str("end"), nl) do |_, _, _, name, _, body, _, _|
          {name, body}
        end
      end

      rule(:method_body) do
        ListParser.new(statement)
      end

      rule(:statement) do
        sequence(literal, nl) do |lit, _|
          lit
        end
      end

      rule(:opt_space) do
        optional(space)
      end

      rule(:literal) do
        AlternativeParser.new(int_literal, string_literal)
      end

      token(:string_literal, /"[^"]*"/, Token)
      token(:int_literal, /[1-9][0-9]*/, Token)
      token(:id,          /[a-zA-Z_][_a-zA-Z0-9]*/, Token)
      token(:space,       /[ \t]+/)
      #token(:opt_space, /[ \t]*/)
      token(:nl,          /[ \t]*[\n;][ \t]*/)
      token(:ws,          /\s*/)
    end

    DJAEVL_CLASS = <<-DJAEVL
      class User
        method age
          30
        end

        method gender
          "male"
        end
      endclass
    DJAEVL

    def test_full_match
      res = DjaevlParser.new.call(DJAEVL_CLASS)
      assert res.full_match?

      assert res.state.parse_log.to_s.size > 0
    end

    def test_ast
      res = DjaevlParser.new.call(DJAEVL_CLASS) as Syntaks::ParseSuccess
      assert res.value == {
        DjaevlParser::Token.new("User"),
        [
          {DjaevlParser::Token.new("age"), [DjaevlParser::Token.new("30")]},
          {DjaevlParser::Token.new("gender"), [DjaevlParser::Token.new("\"male\"")]}
        ]
      }
    end

  end
end
