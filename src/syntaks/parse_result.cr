module Syntaks

  class Success(V)
    getter value : V
    getter end_state : State

    def initialize(@end_state : State, @value : V)
    end
  end

  class Failure
    getter end_state : State

    def initialize(@end_state : State)
    end
  end

  class Error
    getter end_state : State

    def initialize(@end_state : State)
    end
  end

end
