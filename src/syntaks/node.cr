module Syntaks
  abstract class Node
  end

  abstract class InnerNode < Node
    getter children

    def initialize(@children : Array(Node))
    end

    def to_s(depth : Int)
      indent = "  " * depth
      ch_s = children.map{ |c| c.to_s(depth+1) }.join(",\n")
      "#{indent}#{self.class}(\n#{ch_s}\n#{indent})"
    end
  end

  abstract class TerminalNode < Node
    def initialize(@state : ParseState, @interval : SourceInterval)
    end

    def to_s(depth : Int)
      indent = "  " * depth
      indent + self.class.name + "(#{internal_data})"
    end

    private abstract def internal_data
  end

  class IgnoredNode < TerminalNode
    def initialize(@state : ParseState, @interval : SourceInterval)
    end

    private def internal_data
      @interval.to_s
    end
  end
end
