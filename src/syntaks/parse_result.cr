module Syntaks
  class Success(V)
    getter value : V
    getter state : State
    getter end_state : State

    def initialize(@state, @end_state, @value)
    end

    def inspect(io)
      # Override to avoid large output
      io << "#{self.class.name}"
    end
  end

  class Failure
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end

    def inspect(io)
      # Override to avoid large output
      io << "#{self.class.name}"
    end
  end

  class Error
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end

    def message
      # at = end_state.at
      loc = end_state.location

      col = loc.column_number

      line_indicator = "#{loc.line_number}>"

      line = "#{line_indicator}#{loc.line}"
      arrow = "-" * (col + line_indicator.size - 1) + "^"

      <<-MSG
      Syntax error at #{loc}:

      #{line}
      #{arrow}
      Rule: #{rule}

      MSG
    end

    def inspect(io)
      # Override to avoid large output
      io << "#{self.class.name}"
    end
  end
end
