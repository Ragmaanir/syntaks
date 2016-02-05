require "./spec_helper"

module DjaevelParserTests
  class DjaevelTest < Minitest::Test

    class DjaevelParser < Syntaks::FullParser
      include Syntaks::Parsers
      include Syntaks::DSL

      class DjaevelToken
        getter value

        def initialize(token : Token)
          initialize(token.content)
        end

        def initialize(@value : String)
        end

        def ==(other : DjaevelToken)
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

      token(:string_literal, /"[^"]*"/, DjaevelToken)
      token(:int_literal, /[1-9][0-9]*/, DjaevelToken)
      token(:id,          /[a-zA-Z_][_a-zA-Z0-9]*/, DjaevelToken)
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
      res = DjaevelParser.new.call(DJAEVL_CLASS)
      assert res.full_match?

      assert res.state.parse_log.to_s.size > 0
    end

    def test_ast
      res = DjaevelParser.new.call(DJAEVL_CLASS) as Syntaks::ParseSuccess
      assert res.value == {
        DjaevelParser::DjaevelToken.new("User"),
        [
          {DjaevelParser::DjaevelToken.new("age"), [DjaevelParser::DjaevelToken.new("30")]},
          {DjaevelParser::DjaevelToken.new("gender"), [DjaevelParser::DjaevelToken.new("\"male\"")]}
        ]
      }
    end

  end
end
