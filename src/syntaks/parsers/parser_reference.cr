require "../parser"

module Syntaks
  module Parsers
    class ParserReference(T) < Parser(T)

      getter name

      def initialize(@name : String | Symbol, @referenced_parser : -> Parser(T))
      end

      def call(state : ParseState)
        state.parse_log.append(ParseLog::Started.new(self, state.at))
        referenced_parser.call(state)
      end

      def referenced_parser
        @referenced_parser.call
      end

      def to_ebnf
        @name
      end

      def to_ebnf_rule
        "#{to_ebnf} => #{referenced_parser.to_ebnf}"
      end

    end
  end
end
