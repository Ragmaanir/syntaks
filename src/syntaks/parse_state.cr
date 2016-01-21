module Syntaks
  class ParseState

    getter source, at, logger

    def initialize(@source : Source, @at = 0 : Int, @logger = Logger.new(STDOUT))
    end

    def interval(n : Int)
      SourceInterval.new(at, n)
    end

    def forward(n : Int)
      raise ArgumentError.new("n<0") if n < 0
      ParseState.new(source, at + n, logger)
    end

    def remaining_text
      source[at..-1]
    end

    def current_line_start
      source[0..at].rindex("\n") || 0
    end

    def current_line
      if m = source[current_line_start..-1].match(/[^\n]*/)
        m[0].inspect
      else
        ""
        #source[current_line_start..-1][0,10]
        #raise current_line_start.to_s
        #raise "Regex is incorrect: #{source[current_line_start..-1]}"
      end
    end

    def line_number
      # PERFORMANCE cache this
      source[0..at].count("\n")
    end

    def column
      at - current_line_start
    end

    def inspect
      #text = source[at, 16].inspect.colorize(:blue).bold.on(:dark_gray)
      # text = remaining_text[/([^\n]*)/]
      # text = remaining_text[0, 32] if text.size < 10
      # FIXME print current line unless parsing failed at newline or so
      text = remaining_text[0, 32]
      text = text.inspect.colorize(:blue).bold.on(:dark_gray)
      "ParseState(#{at}, #{text})"
    end

  end
end
