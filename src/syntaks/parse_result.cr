module Syntaks
  class Success(V)
    getter value : V
    getter state : State
    getter end_state : State

    def initialize(@state, @end_state, @value)
    end
  end

  class Failure
    # FIXME state?
    # getter state : State
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end
  end

  class Error
    # FIXME state?
    # getter state : State
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end

    def message
      at = end_state.at
      loc = end_state.location

      col = loc.column_number

      line = "#{loc.line_number}>#{loc.line}"
      arrow = "-" * (col - 1 + (Math.log10(col).to_i)) + "^"

      <<-MSG
      Syntax error at #{loc}:

      #{line}
      #{arrow}
      Rule: #{rule}

      MSG
    end
  end
end
