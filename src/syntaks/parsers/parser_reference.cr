require "../parser"

module Syntaks
  module Parsers
    class ParserReference(T) < Parser(T)

      #@referenced_parser :: -> Parser(T)

      #def initialize(&@referenced_parser)
      #end

      def initialize(@referenced_parser : -> Parser(T))
      end

      def call(state : ParseState)# : ParseResult(T)
        referenced_parser.call(state)
      end

      def referenced_parser
        @referenced_parser.call
      end
    end
  end
end
