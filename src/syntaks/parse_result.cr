module Syntaks
  class Success(V)
    getter value : V
    getter end_state : State

    def initialize(@end_state, @value)
    end
  end

  class Failure
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end
  end

  class Error
    getter end_state : State
    getter rule : EBNF::AbstractComponent

    def initialize(@end_state, @rule)
    end
  end
end
