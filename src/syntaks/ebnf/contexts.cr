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
      record RuleInvocation, rule_id : UInt64, started_at : Time, children_time : Float64 = 0.0

      class Stats
        property total_time : Float64 = 0.0
        property children_time : Float64 = 0.0
        property invocation_count : Int32 = 0
        property fail_count : Int32 = 0
        property success_count : Int32 = 0

        def self_time
          total_time - children_time
        end
      end

      getter timings : Hash(UInt64, Stats) = Hash(UInt64, Stats).new
      getter stack : Array(RuleInvocation) = [] of RuleInvocation
      getter rule_names : Hash(UInt64, String) = Hash(UInt64, String).new

      def start_component_call(rule : Component, state : State)
        timings[rule.object_id] ||= Stats.new
        rule_names[rule.object_id] ||= rule.to_s
        stack << RuleInvocation.new(rule.object_id, Time.now)
      end

      def end_component_call(rule : Component, state : State, result : Success | Failure | Error)
        inv = stack.pop

        total = (Time.now - inv.started_at).to_f

        timings[rule.object_id].total_time += total
        timings[rule.object_id].invocation_count += 1

        case result
        when Success then timings[rule.object_id].success_count += 1
        when Failure then timings[rule.object_id].fail_count += 1
        end

        if parent = stack.last?
          timings[parent.rule_id].children_time += total
        end
      end

      def to_s(io : IO)
        print_stats = ->(rule_id : UInt64, stats : Stats) {
          io << "%32s : %5d %5d %5d : %6.1f %6.1f %6.1f" % {
            rule_names[rule_id].colorize(:blue),
            stats.success_count,
            stats.fail_count,
            stats.invocation_count,
            1000*stats.self_time,
            1000 * stats.children_time,
            1000*stats.total_time,
          }
        }

        io << "--- Subrules --- \n"
        io << "%32s : %5s %5s %5s : %6s %6s %6s" % {"name".colorize(:yellow), "succ", "fail", "inv", "self", "child", "total"}
        io << "\n"

        timings.to_a.sort_by { |k, v| v.self_time }.each do |rule_id, stats|
          print_stats.call(rule_id, stats)

          io << "\n"
        end

        io << "--- Named Rules --- \n"
        io << "%32s : %5s %5s %5s : %6s %6s %6s" % {"name".colorize(:yellow), "succ", "fail", "inv", "self", "child", "total"}
        io << "\n"

        timings.select { |k, v| /\A\w+\z/ === rule_names[k] }.to_a.sort_by { |k, v| v.self_time }.each do |rule_id, stats|
          print_stats.call(rule_id, stats)

          io << "\n"
        end
      end
    end
  end # EBNF
end
