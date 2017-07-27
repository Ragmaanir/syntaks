require "./ebnf/component"

module Syntaks
  class ParseLog
    abstract class Entry
      getter rule : EBNF::AbstractComponent
      getter from : Int32

      def initialize(@rule, @from)
      end
    end

    class Success < Entry
      getter to : Int32

      def initialize(@rule, @from, @to)
      end
    end

    class Failure < Entry
    end

    class Error < Entry
    end

    class Started < Entry
      def initialize(@rule, @from)
      end
    end

    getter source : Source
    getter log : Array(Entry)

    def initialize(@source)
      @log = [] of Entry
    end

    def append(entry : Entry)
      @log << entry
    end

    def printable_array
      @log.map do |entry|
        h = Highlighter.new(source[0..-1])

        case entry
        when Started
          r = entry.rule.as((EBNF::Component))
          h.highlight(entry.from, :white, :yellow)
          [
            ["STARTED".colorize(:yellow), ": ", r.to_s.colorize(:blue), " at (#{entry.from}):".colorize(:dark_gray)].join,
            h.to_s,
          ].join("\n")
        when Success
          h.highlight(entry.from, entry.to, :white, :green)
          [
            ["SUCCEEDED".colorize(:green), ": ", entry.rule.to_s.colorize(:blue), " at (#{entry.from}-#{entry.to}):".colorize(:dark_gray)].join,
            h.to_s,
          ].join("\n")
        when Failure
          h.highlight(entry.from, :white, :red)
          [
            ["FAILED".colorize(:red), ": ", entry.rule.to_s.colorize(:blue), " at (#{entry.from}):".colorize(:dark_gray)].join,
            h.to_s,
          ].join("\n")
        when Error
          h.highlight(entry.from, :white, :red)
          [
            ["ERROR".colorize(:red), ": ", entry.rule.to_s.colorize(:blue), " at (#{entry.from}):".colorize(:dark_gray)].join,
            h.to_s,
          ].join("\n")
        end
      end
    end

    def to_s(io)
      io << printable_array.flatten.join("\n")
    end

    def replay
      printable_array.each do |entry|
        puts entry
        break if gets == "q\n"
      end
    end
  end
end
