require "../parse_log"

module Syntaks
  module EBNF
    abstract class Context
      abstract def on_non_terminal(rule : Component, state : State)
      abstract def on_success(rule : Component, state : State, end_state : State)
      abstract def on_failure(rule : Component, state : State)
      abstract def on_error(rule : Component, state : State)
    end

    class EmptyContext < Context
      def on_non_terminal(rule : Component, state : State)
      end

      def on_success(rule : Component, state : State, end_state : State)
      end

      def on_failure(rule : Component, state : State)
      end

      def on_error(rule : Component, state : State)
      end
    end

    class LoggingContext < Context
      getter parse_log : ParseLog

      def initialize(@parse_log)
      end

      def on_non_terminal(rule : Component, state : State)
        parse_log.append(ParseLog::Started.new(rule, state.at))
      end

      def on_success(rule : Component, state : State, end_state : State)
        parse_log.append(ParseLog::Success.new(rule, state.at, end_state.at))
      end

      def on_failure(rule : Component, state : State)
        parse_log.append(ParseLog::Failure.new(rule, state.at))
      end

      def on_error(rule : Component, state : State)
        # FIXME store parse errors
      end
    end
  end
end
