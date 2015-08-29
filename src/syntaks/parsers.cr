module Syntaks

  class StringParser < Parser
    def initialize(@string)
    end

    def call(state : ParseState) : ParseResult
      if state.to_s.starts_with?(@string)
        interval = state.interval(@string.length)
        end_state = state.forward(interval.length)
        node = IgnoredNode.new(state, interval)
        succeed(state, end_state, node)
      else
        fail(state)
      end
    end

    def to_s
      "#{canonical_name}(#{@string.inspect})"
    end
  end

  class TokenParser(T) < Parser
    getter :token

    def initialize(@token : String | Regex)
    end

    def call(state : ParseState) : ParseResult
      parsed_text = case t = @token
      when String
        t if state.to_s.starts_with?(t)
      when Regex
        if m = t.match(state.to_s)
          m[0]
        end
      end

      if parsed_text
        interval = state.interval(parsed_text.length)
        end_state = state.forward(parsed_text.length)
        node = T.new(state, interval)
        succeed(state, end_state, node)
      else
        fail(state)
      end
    end
  end

  class SequenceParser(T) < Parser
    def initialize(@seq : Array(Parser), &@block : Array(Node) -> T)
    end

    def call(state : ParseState) : ParseResult
      at = state.at
      results = call_children(state)

      if results.length == @seq.length
        nodes = results.map{ |r| r.node as Node }

        final_state = results.last.end_state as ParseState

        node = @block.call(nodes) as T
        succeed(state, final_state, node)
      else
        fail(state)
      end
    end

    private def call_children(state : ParseState) : Array(ParseSuccess)
      results = [] of ParseSuccess
      current_state = state

      @seq.find do |parser|
        case result = parser.call(current_state)
        when ParseSuccess
          results << result
          current_state = result.end_state
          false
        when ParseFailure
          true
        end
      end

      results
    end
  end

  class OptionalParser(N) < Parser
    def initialize(@parser)
    end

    def call(state : ParseState) : ParseResult
      case res = @parser.call(state)
      when ParseSuccess
        succeed(state, res.interval, N.new(res.node))
      when ParseFailure
        succeed(state, state.interval(0), N.new)
      end
    end
  end

  class ListParser(T) < Parser
    def initialize(@parser : Parser, @seperator_parser : Parser)
      @sequence = SequenceParser(Node).new([@seperator_parser, @parser]) do |args|
        args[1]
      end
    end

    def call(state : ParseState) : ParseResult
      case res = @parser.call(state)
      when ParseSuccess
        results = [res] + parse_tail(res.end_state)

        final_state = results.last.end_state as ParseState
        children = results.map{ |r| r.node as Node }

        node = T.new(children)

        succeed(state, final_state, node)
      when ParseFailure
        fail(state)
      else raise "Unknown parse result"
      end
    end

    private def parse_tail(state : ParseState) : Array(ParseSuccess)
      success = true
      results = [] of ParseSuccess
      current_state = state

      while success
        res = @sequence.call(current_state)

        case res
        when ParseSuccess
          results << res
          current_state = res.end_state
        when ParseFailure
          success = false
        end
      end

      results
    end

  end

end
