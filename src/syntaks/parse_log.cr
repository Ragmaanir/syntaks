module Syntaks
  abstract class RuleProgress
    getter rule
  end

  class RuleStart < RuleProgress

    getter location

    def initialize(@rule, @location : Source::Location)
    end

    def to_s
      "RuleStart(#{rule}, #{location})"
    end
  end

  class RuleEnd < RuleProgress

    getter start_location, end_location

    def initialize(@rule, @start_location : Source::Location, @end_location : Source::Location)
    end

    def to_s
      "RuleEnd(#{rule}, #{start_location}, #{end_location})"
    end
  end

  class ProgressLog

    getter source, log

    def initialize(@source : Source)
      @log = [] of RuleProgress
    end

    def append(entry : RuleProgress)
      @log << entry
    end

    private def printable_array
      @log.map do |entry|
        h = Highlighter.new(source.text)

        case entry
        when RuleStart
          h.highlight(entry.location.offset, entry.location.offset, :white, :yellow)
          [
            "Trying #{entry.rule} at line(#{entry.location}):",
            h.to_s
          ].join("\n")
        when RuleEnd
          h.highlight(entry.start_location.offset, entry.end_location.offset, :white, :green)
          [
            "Parsed #{entry.rule} at line(#{entry.start_location}):",
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
