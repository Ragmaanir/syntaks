module Syntaks
  class ParseLog

    abstract class Entry
      getter rule, from

      def initialize(@rule, @from : Int)
      end
    end

    class Success < Entry
      getter to

      def initialize(@rule, @from : Int, @to : Int)
      end
    end

    class Failure < Entry
    end

    class Started < Entry
      def initialize(@rule, @from : Int)
      end
    end

    getter source, log

    def initialize(@source : Source)
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
            r = entry.rule as(Parsers::ParserReference)
            h.highlight(entry.from, :white, :yellow)
            [
              ["STARTED".colorize(:yellow), ": ", r.to_ebnf_rule.colorize(:blue), " at (#{entry.from}):".colorize(:dark_gray)].join,
              h.to_s
            ].join("\n")
          when Success
            h.highlight(entry.from, entry.to, :white, :green)
            [
              ["SUCCEEDED".colorize(:green), ": ", entry.rule.to_ebnf.colorize(:blue), " at (#{entry.from}-#{entry.to}):".colorize(:dark_gray)].join,
              h.to_s
            ].join("\n")
          when Failure
            h.highlight(entry.from, :white, :red)
            [
              ["FAILED".colorize(:red), ": ", entry.rule.to_ebnf.colorize(:blue), " at (#{entry.from}):".colorize(:dark_gray)].join,
              h.to_s
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
