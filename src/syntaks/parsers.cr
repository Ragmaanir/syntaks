module Syntaks

  class StringParser < Parser
    def initialize(@string)
    end

    def call(state) : ParseResult
      from = state.at

      if state.to_s.starts_with?(@string)
        interval = state.interval(@string.length)
        state.forward(interval.length)
        node = IgnoredNode.new(state, interval)
        succeed(state, interval, node)
      else
        fail(state)
      end
    end

    def to_s
      "#{self.class.name}(#{@string.inspect})"
    end
  end

  class TokenParser(T) < Parser
    getter :token

    def initialize(@token : String | Regex)
    end

    def call(state)
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
        state.forward(interval.length)
        node = T.new(state, interval)
        succeed(state, interval, node)
      else
        fail(state)
      end
    end
  end

  class SequenceParser(T) < Parser
    def initialize(@seq : Array(Parser), &@block : Array(Node) -> T)
    end

    def call(state)
      at = state.at
      results = call_children(state)

      if results.length == @seq.length
        nodes = results.map{ |r| r.node as Node }

        node = @block.call(nodes) as T
        succeed(state, SourceInterval.new(state.source, at, state.at-at), node)
      else
        fail(state)
      end
    end

    private def call_children(state)
      results = [] of ParseSuccess

      @seq.find do |parser|
        case result = parser.call(state)
        when ParseSuccess
          results << result
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

    def call(state)
      case res = @parser.call(state)
      when ParseSuccess
        succeed(state, res.interval, N.new(res.node))
      when ParseFailure
        succeed(state, state.interval(0), N.new)
      end
    end
  end

  class ListParser(T) < Parser
    def initialize(@parser, @seperator_parser)
    end

    def call(state) : ParseResult
      at = state.at

      case res = @parser.call(state)
      when ParseSuccess
        results = [res] + parse_tail(state)

        children = results.map{ |r| r.node as Node }

        node = T.new(children)

        return succeed(state, SourceInterval.new(state.source, at, state.at - at), node)
      when ParseFailure
        return fail(state)
      else raise "Unknown parse result"
      end
    end

    private def parse_tail(state) : Array(ParseSuccess)
      success = true
      results = [] of ParseSuccess

      while success
        sep_result = @seperator_parser.call(state)
        parser_res = @parser.call(state)

        success = sep_result.success? && parser_res.success?

        results << parser_res as ParseSuccess if success
      end

      results
    end

  end

end
