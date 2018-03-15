require "../parse_log"

module Syntaks
  module EBNF
    abstract class Context
      abstract def start_component_call(rule : Component, state : State)
      abstract def end_component_call(rule : Component, state : State, result : Success | Failure | Error)
    end

    class EmptyContext < Context
      def start_component_call(rule : Component, state : State)
      end

      def end_component_call(rule : Component, state : State, result : Success | Failure | Error)
      end
    end

    class LoggingContext < Context
      getter parse_log : ParseLog

      def initialize(@parse_log)
      end

      def start_component_call(rule : Component, state : State)
        parse_log.log_start(rule, state.at)
      end

      def end_component_call(rule : Component, state : State, result : Success | Failure | Error)
        parse_log.log_end(rule, state, result)
      end
    end

    class ProfilingContext < Context
      record RuleInvocation, exp : String, started_at : Time, children_time : Float64 = 0.0
      record TimingStats, total_time : Float64, children_time : Float64 do
        def self_time
          total_time - children_time
        end
      end

      getter timings : Hash(String, TimingStats) = Hash(String, TimingStats).new
      getter stack : Array(RuleInvocation) = [] of RuleInvocation

      def start_component_call(rule : Component, state : State)
        stack << RuleInvocation.new(rule.to_s, Time.now)
      end

      def end_component_call(rule : Component, state : State, result : Success | Failure | Error)
        inv = stack.pop

        timings[rule.to_s] ||= TimingStats.new((Time.now - inv.started_at).to_f, inv.children_time)
        timings[rule.to_s] += 0
      end
    end
  end
end
