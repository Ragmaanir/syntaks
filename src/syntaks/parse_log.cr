require "./ebnf/component"

module Syntaks
  class ParseLog
    abstract class Entry
      getter rule : EBNF::AbstractComponent

      def initialize(@rule)
      end
    end

    class Start < Entry
      getter from : Int32

      def initialize(@rule, @from)
      end
    end

    class End < Entry
      enum Kind
        SUCCESS
        FAILURE
        ERROR

        def self.from_result(res : Success | Failure | Error)
          case res
          when Success then Kind::SUCCESS
          when Failure then Kind::FAILURE
          else              Kind::ERROR
          end
        end
      end

      # FIXME rule
      getter from : Int32
      getter to : Int32
      getter kind : Kind

      def initialize(@rule, @kind, @from, @to)
      end
    end

    getter source : Source
    getter log : Array(Entry)

    def initialize(@source)
      @log = [] of Entry
    end

    def log_start(rule : EBNF::Component, start : Int32)
      @log << Start.new(rule, start)
    end

    def log_end(rule : EBNF::Component, state : State, result : Success | Failure | Error)
      @log << End.new(rule, End::Kind.from_result(result), state.at, result.end_state.at)
    end

    DOT   = "•"
    ARROW = "↳"
    TICK  = "✓"
    CROSS = "✕"
    ERROR = "⚡"

    private def excerpt(at : Int32)
      pre = if at > 0
              source[[at - 4, 0].max..[at - 1, 0].max]
            end

      current = source[at, 1]
      post = source[[at + 1, source.size].min, 16]

      {pre.try(&.gsub("\n", "\\n")), current.gsub("\n", "\\n"), post.gsub("\n", "\\n")}
    end

    private def excerpt(from : Int32, at : Int32)
      pre = if at > 0
              source[[[at - 8, [from, at - 16].max].min, 0].max..[at - 1, 0].max]
            end

      current = source[at, 1]
      post = source[[at + 1, source.size].min, 16]

      {pre.try(&.gsub("\n", "\\n")), current.gsub("\n", "\\n"), post.gsub("\n", "\\n")}
    end

    private def print_start(entry : Start)
      pre, current, post = excerpt(entry.from)

      excerpt = [
        pre.colorize(:black).on(:green),
        current.colorize(:black).on(:white),
        post.colorize(:dark_gray),
      ].join

      [
        ARROW,
        " ",
        entry.rule.to_s.colorize(:blue),
        "\t",
        " at (#{entry.from}): ".colorize(:dark_gray),
        excerpt,
      ].join
    end

    MARKER_MAP = {
      End::Kind::SUCCESS => TICK,
      End::Kind::FAILURE => CROSS,
      End::Kind::ERROR   => ERROR,
    }

    COLOR_MAP = {
      End::Kind::SUCCESS => :green,
      End::Kind::FAILURE => :yellow,
      End::Kind::ERROR   => :red,
    }

    private def print_end(entry : End)
      start = if entry.to > 0
                [entry.to - 8, 0].max
              end

      pre, current, post = excerpt(entry.from, entry.to)

      color = COLOR_MAP.fetch(entry.kind)

      excerpt = [
        pre.colorize(:black).on(color),
        current.colorize(:black).on(:white),
        post.colorize(:dark_gray),
      ].join

      marker = MARKER_MAP.fetch(entry.kind).colorize(color)

      [
        marker,
        " ",
        entry.rule.to_s.colorize(:blue),
        "\t",
        " at (#{entry.from}-#{entry.to}): ".colorize(:dark_gray),
        excerpt,
      ].join
    end

    def to_s(io : IO)
      indent_depth = 0
      indent = ->{ "  " * indent_depth }

      @log.each do |entry|
        case entry
        when Start
          io << indent.call
          io << print_start(entry)

          indent_depth += 1
        when End
          indent_depth -= 1

          io << indent.call
          io << print_end(entry)
        end

        io << "\n"
      end
    end

    # def replay
    #   printable_array.each do |entry|
    #     puts entry
    #     break if gets == "q\n"
    #   end
    # end
  end
end
