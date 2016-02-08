require "../parser"

module Syntaks
  module Parsers
    class ParserReference(X,Y) < Parser(X)

      getter name

      def self.build(name : String | Symbol, referenced_parser : -> Parser(X))
        ParserReference(X,X).new(name, referenced_parser, ->(x : X) { x })
      end

      def self.build(name : String | Symbol, referenced_parser : -> Parser(X), callback : X -> Y)
        ParserReference(X,Y).new(name, referenced_parser, callback)
      end

      def initialize(@name : String | Symbol, @referenced_parser : -> Parser(X), @callback : X -> Y)
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

      def to_structure
        "ParserReference(#{name}, #{referenced_parser.to_structure})"
      end

    end
  end
end
