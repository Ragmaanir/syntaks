module Syntaks
  class Success(V)
    getter value : V
    getter end_state : State

    def initialize(@end_state, @value)
    end
  end

  class Failure
    getter end_state : State

    def initialize(@end_state)
    end
  end

  class Error
    getter end_state : State

    def initialize(@end_state)
    end
  end
end
