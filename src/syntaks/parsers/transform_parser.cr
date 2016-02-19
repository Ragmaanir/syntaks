require "../parser"

module Syntaks
  module Parsers
    class TransformParser(X, Y) < Parser(Y)

      getter name, referenced_parser, transform

      def self.build(referenced_parser : Parser(X), &transform : X -> Y)
        TransformParser(X, Y).new(referenced_parser, transform)
      end

      def initialize(@referenced_parser : Parser(X), @transform : X -> Y)
      end

      def call(state : ParseState)
        case result = referenced_parser.call(state)
        when ParseSuccess
          succeed(result.state, result.end_state, transform.call(result.value))
        else
          fail(result.state)
        end
      end

      def to_ebnf
        referenced_parser.to_ebnf
      end

      def to_ebnf_rule
        "#{to_ebnf} => #{referenced_parser.to_ebnf} # #{X} -> #{Y}"
      end

      def to_structure
        "#{self.canonical_name}(#{name}, #{referenced_parser.to_structure})"
      end

    end
  end
end
