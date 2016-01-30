require "colorize"

module Syntaks
  class Highlighter
    class Command
      getter from, to, foreground, background

      def initialize(@from : Int, @to : Int, @foreground : Symbol, @background : Symbol)
      end
    end

    include Kontrakt

    def initialize(@string : String)
      @commands = [] of Command
      highlight(0, @string.size-1, :white, :black)
    end

    def highlight(idx : Int, foreground : Symbol, background : Symbol)
      precondition(idx >= 0 && idx <= @string.size)
      end_idx = [idx+1, @string.size].min
      highlight(idx, end_idx, foreground, background)
    end

    def highlight(start_idx : Int, end_idx : Int, foreground : Symbol, background : Symbol)
      precondition(start_idx >= 0 && start_idx <= end_idx)
      precondition(end_idx <= @string.size)
      @commands << Command.new(start_idx, end_idx, foreground, background)
    end

    def to_s(io)
      colors = Array(Tuple(Symbol,Symbol)).new(@string.size) do
        Tuple.new(:white, :black)
      end

      @commands.each do |cmd|
        cmd.from.upto(cmd.to-1) do |i|
          colors[i] = Tuple.new(cmd.foreground, cmd.background)
        end
      end

      result = [] of Colorize::Object(String)
      @string.each_char.each_with_index do |c, i|
        char = case c
          when '\t' then "\\t"
          when '\n' then "\\n"
          else c.to_s
        end

        result << char.colorize(colors[i][0]).on(colors[i][1])
      end

      io << result.join
    end
  end
end
