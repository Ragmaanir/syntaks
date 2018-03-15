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
  end
end
