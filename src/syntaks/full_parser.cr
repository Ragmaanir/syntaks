require "./parser"
require "./parsers/sequence_parser"
require "./parsers/alternative_parser"
require "./parsers/list_parser"

module Syntaks
  abstract class FullParser # FIXME should be generic
    include Syntaks::Parsers

    abstract def root : Parser(T) # FIXME T should be the generic parameter

    def call(input : String)
      call(Source.new(input))
    end

    def call(source : Source)
      root.call(ParseState.new(source, 0, ParseLog.new(source)))
    end

  end
end
