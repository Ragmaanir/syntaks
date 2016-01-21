module Syntaks
  class ParseLog

    class Entry
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

    private def printable_array
      @log.map do |entry|
        h = Highlighter.new(source[0..-1])

        case entry
          when Started
            r = entry.rule as(Parsers::ParserReference)
            h.highlight(entry.from, entry.from+1, :white, :yellow)
            [
              #"Trying #{entry.rule} at line(#{entry.location}):",
              "Rule #{r.to_ebnf_rule} started at (#{entry.from}):",
              h.to_s
            ].join("\n")
          when Success
            h.highlight(entry.from, entry.to, :white, :green)
            [
              #"Parsed #{entry.rule} at line(#{entry.start_location}):",
              "Rule #{entry.rule.to_ebnf} succeeded at (#{entry.from}-#{entry.to}):",
              h.to_s
            ].join("\n")
          when Failure
            h.highlight(entry.from, entry.from+1, :white, :red)
            [
              #"Trying #{entry.rule} at line(#{entry.location}):",
              "Rule #{entry.rule.to_ebnf} failed at (#{entry.from}):",
              h.to_s
            ].join("\n")
        end
      end
    end

    def to_s
      printable_array.flatten.join("\n")
    end

    def replay
      printable_array.each do |entry|
        puts entry
        break if gets == "q\n"
      end
    end

  end
end
