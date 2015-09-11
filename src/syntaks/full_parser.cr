require "./parser"
require "./parsers/sequence_parser"
require "./parsers/alternative_parser"
require "./parsers/list_parser"

module Syntaks
  abstract class FullParser # FIXME should be generic
    include Syntaks::Parsers

    abstract def root : Parser(T) # FIXME T should be the generic parameter

    def call!(input : String)
      logger = Logger.new(STDOUT)
      logger.level = Logger::Severity::DEBUG
      call(input, logger)
    end

    def call(input : String, logger = Logger.new(STDOUT) : Logger)
      call(Source.new(input), logger)
    end

    def call(source : Source, logger = Logger.new(STDOUT) : Logger)
      root.call(ParseState.new(source, logger: logger))
    end

  end
end
