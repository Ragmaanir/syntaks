module Syntaks
  abstract class Node
  end

  class IgnoredNode < Node
    def initialize(@state : ParseState, @interval : SourceInterval)
    end
  end
end
