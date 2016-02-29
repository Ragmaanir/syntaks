module Syntaks
  module EBNF

    class Source
      getter content

      delegate size, content
      def initialize(@content : String)
      end

      def [](from, length)
        content[from, length]
      end

      def [](range : Range)
        content[range]
      end
    end

    class Token
      getter interval

      def initialize(@interval : SourceInterval)
      end

      def content
        interval.content
      end

      def to_s(io)
        io << "Token(#{interval}, #{content.inspect})"
      end

      def inspect(io)
        to_s(io)
      end
    end

    class SourceInterval

      include Kontrakt

      getter source, from, length

      def initialize(@source : Source, @from : Int, @length=0 : Int)
        precondition(from >= 0)
        precondition(length >= 0)
      end

      def from_location
        SourceLocation.new(source, from)
      end

      def to_location
        SourceLocation.new(source, to)
      end

      def to
        from + length - 1
      end

      def content
        source[from..to]
      end

      def to_s(io)
        io << "SourceInterval(#{from_location},#{to_location})"
      end

      def inspect(io)
        to_s(io)
      end

    end

    class SourceLocation
      include Kontrakt

      getter source, at

      def initialize(@source : Source, @at : Int)
        precondition(at >= 0)
      end

      def line_number
        source[0..at].count("\n")
      end

      def column_number
        at - (source[0..at].rindex("\n") || 0)
      end

      def line
        source[line_start..line_end]
      end

      def line_start
        @line_start ||= source[0..at].rindex("\n") || 0
      end

      def line_end
        @line_end ||= line_start + (source[line_start..-1].index("\n") || 0)
      end

      def to_s(io)
        io << "#{line_number}:#{column_number}"
      end
    end

    class State
      include Kontrakt
      getter source, at

      def initialize(@source : Source, @at : Int)
        precondition(at <= source.size)
      end

      def remaining_text
        source.content[at..-1]
      end

      def advance(n : Int)
        State.new(source, at + n)
      end

      def interval(length : Int)
        SourceInterval.new(source, at, length)
      end

      def to_s(io)
        io << "State(#{at})"
      end

      def inspect(io)
        to_s(io)
      end
    end

    abstract class Result
      def success? : Boolean
        false
      end
    end

    class Success(V) < Result
      getter value : V
      getter end_state : State

      def initialize(@end_state : State, @value : V)
      end

      def success?
        true
      end
    end

    class Failure < Result
    end

    class Error < Result
    end

    abstract class Component(V)
      def short_name
        self.class.name.split("::").last
      end

      abstract def simple? : Boolean
      abstract def call(state : State) : Success(V) | Failure | Error
    end

    class Seq(L,R,V) < Component(V)
      getter left, right

      def self.build(left : Component(L), right : Component(R), action : (L,R) -> V)
        new(left, right, action)
      end

      def self.build(left : Component(L), right : Component(R))
        Seq(L, R, {L,R}).new(left, right, ->(l : L, r : R){ {l,r} })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L,R) -> V)
      end

      def call(state : State)
        case lr = left.call(state)
          when Success
            case rr = right.call(lr.end_state)
              when Success
                Success(V).new(rr.end_state, {lr.value, rr.value})
              when Failure
                rr
              when Error
                rr
            end
          when Failure
            lr
          when Error
            lr
        end
      end

      def simple?
        false
      end

      def ==(other : Seq)
        other.left == left && other.right == right
      end

      def to_s(io)
        io << "#{left} >> #{right}"
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end

    class Alt(L,R,V) < Component(V)
      getter left, right

      def self.build(*args)
        new(*args)
      end

      def self.build(left : Component(L), right : Component(R))
        Alt(L,R, L | R).new(left, right, ->(r : L | R){ r })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L | R) -> V)
      end

      def call(state : State)
        case lr = left.call(state)
        when Success
          Success(V).new(state, lr.value)
        when Failure
          case rr = right.call(state)
          when Success then Success(V).new(state, rr.value)
          else rr
          end
        else lr
        end
      end

      def simple?
        false
      end

      def ==(other : Alt)
        other.left == left && other.right == right
      end

      def to_s(io)
        io << "#{left} | #{right}"
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end

    class Opt(V) < Component(V?)
      getter rule
      def initialize(@rule : Component(V))
      end

      def call(state : State)
        case r = rule.call(state)
        when Success then Success(V).new(r.end_state, r.value)
        else Success(V?).new(state, nil)
        end
      end

      def simple?
        true
      end

      def ==(other : Opt)
        other.rule == rule
      end

      def to_s(io)
        str = if rule.simple?
          "~#{rule}"
        else
          "~(#{rule})"
        end
        io << str
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end

    class Rep(V) < Component(Array(V))
      getter rule
      def initialize(@rule : Component(V))
      end

      def call(state : State)
        case r = rule.call(state)
        when Success then Success(Array(V)).new(state, [r.value])
        else r
        end
      end

      def simple?
        true
      end

      def ==(other : Rep)
        other.rule == rule
      end

      def to_s(io)
        io << "{#{rule}}"
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end

    class NonTerminal(R, V) < Component(V)
      getter name, referenced_rule, action

      def self.build(name : String, referenced_rule : -> Component(R))
        new(name, referenced_rule, ->(r : R) { r })
      end

      def self.build(name : String, referenced_rule : -> Component(R), &action : R -> V)
        new(name, referenced_rule, action)
      end

      def initialize(@name : String, @referenced_rule : -> Component(R), @action : R -> V)
      end

      def call(state : State)
        r = referenced_rule.call.call(state)
        case r
          when Success(R) then Success.new(r.end_state, action.call(r.value))
          else r
        end
      end

      def simple?
        true
      end

      def ==(other : NonTerminal)
        other.name == name
      end

      def to_s(io)
        io << name
      end

      def inspect(io)
        io << name
      end
    end

    class Terminal(V) < Component(V)
      getter matcher

      def self.build(matcher : String | Regex)
        new(matcher, ->(t : Token){ t })
      end

      def self.build(matcher : String | Regex, action : Token -> V)
        new(matcher, action)
      end

      def initialize(@matcher : String | Regex, @action : Token -> V)
      end

      def call(state : State)
        parsed_text = case m = matcher
          when String
            m if state.remaining_text.starts_with?(m)
          when Regex
            if r = Regex.new("\\A"+m.source).match(state.remaining_text)
              r[0]
            end
        end

        if parsed_text
          end_state = state.advance(parsed_text.size)
          token = Token.new(state.interval(parsed_text.size))
          value = @action.call(token)
          Success(V).new(end_state, value)
        else
          Failure.new
        end
      end

      def simple?
        true
      end

      def ==(other : Terminal)
        other.matcher == matcher
      end

      def to_s(io)
        io << matcher.inspect
      end

      def inspect(io)
        io << matcher.inspect
      end
    end

    macro rule(name, sequence, &action)
      def {{name.id}}
        @{{name.id}} ||= NonTerminal.build("{{name.id}}", ->{ build_ebnf({{sequence}}) }) {{action}}
      end
    end

    # macro rule(name, sequence, &action)
    #   def {{name.id}}
    #     @{{name.id}} ||= NonTerminal.build("{{name.id}}", ->{ build_ebnf({{sequence}}) }, {{action}})
    #   end
    # end

    macro build_ebnf(arg)
      {%
        t = arg.class_name
        res = if t == "Call"
          argname = "#{arg.name}"
          if arg.receiver && [">>", "&"].includes?(argname)
            "Seq.build(build_ebnf(#{arg.receiver}), build_ebnf(#{arg.args.first}))"
          elsif argname == "|"
            "Alt.build(build_ebnf(#{arg.receiver}), build_ebnf(#{arg.args.first}))"
          elsif argname == "~"
            "Opt.new(build_ebnf(#{arg.receiver}))"
          else
            "NonTerminal.build(\"#{arg.name}\", ->{ #{arg.name} })"
          end
        elsif t == "TupleLiteral"
          "Rep.new(build_ebnf(#{arg[0]}))"
        elsif %w{StringLiteral RegexLiteral}.includes?(t)
          "Terminal.build(#{arg})"
        else
          "NonTerminal.build(\"#{arg}\", ->{ #{arg} })"
        end
      %}
      {{res.id}}
    end

    # DEBUG
    macro classof(exp)
      {% t = exp.class_name %}
      puts "CLASS: {{t.id}} EXP: {{exp.id}}"
    end
  end
end
