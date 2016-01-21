require "logger"

module Syntaks
  abstract class Parser(T)
    #abstract def call(state : ParseState) : ParseSuccess(T) | ParseFailure | ParseError
    abstract def call(state : ParseState) : ParseResult

    private def succeed(state, end_state, value : T)
      # diff = end_state.at - state.at
      # parsed_text = state.remaining_text[0, diff].inspect[1..-2].colorize(:white).bold.on(:green)
      # remaining_text = end_state.remaining_text[0, 12].inspect[1..-2].colorize(:white).on(:blue)

      state.parse_log.append(ParseLog::Success.new(self, state.at, end_state.at))
      ParseSuccess(T).new(self, state, end_state, value)
    end

    private def fail(state, last_success = nil : ParseSuccess?)
      state.parse_log.append(ParseLog::Failure.new(self, state.at))
      ParseFailure.new(self, state, last_success)
    end

    private def error(state)
      state.parse_log.append(ParseLog::Failure.new(self, state.at))
      ParseFailure.new(self, state, nil)
    end

    def to_s
      canonical_name
    end

    def canonical_name
      if self.class.name.includes?("(")
        if m = self.class.name.match(/.*::([a-zA-Z0-9]+\(.*)/)
          m[1]
        end
      else
        self.class.name.split("::").last
      end
    end

    abstract def to_ebnf : String
    abstract def to_structure : String
  end
end
