module Syntaks
  abstract class Node
  end

  abstract class InnerNode < Node
    getter :children

    def initialize(@children : Array(Node))
    end

    def to_s(depth : Int)
      indent = "  " * depth
      ch_s = children.map{ |c| "\n" + c.to_s(depth+1) + "\n#{indent}" }.join(",")
      "#{indent}#{self.class}(#{ch_s})"
    end
  end

  abstract class TerminalNode < Node
    def to_s(depth : Int)
      indent = "  " * depth
      indent + self.class.name
    end
  end

  class IgnoredNode < TerminalNode
    def initialize(@state : ParseState, @interval : SourceInterval)
    end
  end
end
