module Syntaks
  module Parsers
    class ParserReference < Parser
      def initialize(&@ref : -> Parser)
      end

      def initialize(@ref : -> Parser)
      end

      def call(state : ParseState) : ParseResult
        @ref.call.call(state)
      end
    end
  end
end
