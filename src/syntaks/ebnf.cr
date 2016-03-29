module Syntaks
  module EBNF

    abstract class Component(V)
      def short_name
        self.class.name.split("::").last
      end

      abstract def simple? : Boolean
      abstract def call(state : State) : Success(V) | Failure | Error

      private def succeed(state : State, value : V) : Success(V)
        Success(V).new(state, value)
      end

      private def fail(state : State) : Failure
        Failure.new(state)
      end

      private def error(state : State) : Error
        Error.new(state)
      end
    end

    class Seq(L,R,V) < Component(V)
      getter left, right

      def self.build(left : Component(L), right : Component(R), &action : (L,R) -> V)
        Seq(L, R, V).new(left, right, ->(l : L, r : R){ action.call(l,r) })
      end

      def self.build(left : Component(L), right : Component(R), action : (L,R) -> V)
        new(left, right, action)
      end

      def self.build(left : Component(L), right : Component(R))
        Seq(L, R, {L,R}).new(left, right, ->(l : L, r : R){ {l,r} })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L,R) -> V)
      end

      def call(state : State) : Success(V) | Failure | Error
        case lr = left.call(state)
          when Success
            case rr = right.call(lr.end_state)
              when Success
                succeed(rr.end_state, @action.call(lr.value, rr.value))
              when Failure
                fail(rr.end_state)
              else
                error(rr.end_state)
            end
          when Failure
            fail(state)
          else
            error(state)
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

      def call(state : State) : Success(V) | Failure | Error
        case lr = left.call(state)
        when Success
          succeed(state, lr.value)
        when Failure
          case rr = right.call(state)
          when Success then succeed(state, rr.value)
          when Failure then fail(rr.end_state)
          else error(rr.end_state)
          end
        else error(state)
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

      def call(state : State) : Success(V?) | Failure | Error
        case r = rule.call(state)
        when Success then succeed(r.end_state, r.value)
        when Failure then succeed(state, nil)
        else error(state)
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

      def call(state : State) : Success(Array(V)) | Failure | Error
        # FIXME repetition
        case r = rule.call(state)
        when Success then succeed(state, [r.value])
        when Failure then fail(r.end_state)
        else error(r.end_state)
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
        NonTerminal(R, R).new(name, referenced_rule, ->(r : R) { r })
      end

      def self.build(name : String, referenced_rule : -> Component(R), &action : R -> V)
        NonTerminal(R, V).new(name, referenced_rule, action)
      end

      def initialize(@name : String, @referenced_rule : -> Component(R), @action : R -> V)
      end

      def call(state : State) : Success(V) | Failure | Error
        r = referenced_rule.call.call(state)
        case r
        when Success(R) then succeed(r.end_state, action.call(r.value))
        else fail(state)
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

      def call(state : State) : Success(V) | Failure | Error
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
          succeed(end_state, value)
        else
          fail(state)
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

  end
end
