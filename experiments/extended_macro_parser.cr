module EBNF
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

  class Token
    getter interval

    delegate content, to: interval

    def initialize(@interval : SourceInterval)
    end

    def to_s(io)
      io << "Token(#{interval}, #{content.inspect})"
    end

    def inspect(io)
      to_s(io)
    end
  end

  class Source
    getter content

    delegate size, to: content

    def initialize(@content : String)
    end

    def [](from, length)
      content[from, length]
    end

    def [](range : Range)
      content[range]
    end
  end

  class SourceLocation
    getter source : Source
    getter at : Int32

    def initialize(@source : Source, @at : Int)
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
      # @line_end ||= line_start + (source[line_start..-1].index("\n") || 0)
      line_start + (source[line_start..-1].index("\n") || 0)
      # FIXME memoization. causes type errors ATM
    end

    def to_s(io)
      io << "#{line_number}:#{column_number}"
    end
  end

  class SourceInterval
    getter source : Source
    getter from : Int32
    getter length : Int32

    def initialize(@source : Source, @from : Int, @length : Int = 0)
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

  class State
    getter source : Source
    getter at : Int32

    def initialize(@source : Source, @at : Int)
    end

    def remaining_text
      source.content[at..-1]
    end

    def advance(n : Int)
      State.new(source, at + n)
    end

    def location
      SourceLocation.new(source, at)
    end

    def interval(length : Int)
      SourceInterval.new(source, at, length)
    end

    def display
      # text = source[at, 16].inspect.colorize(:blue).bold.on(:dark_gray)
      # text = remaining_text[/([^\n]*)/]
      # text = remaining_text[0, 32] if text.size < 10
      # FIXME print current line unless parsing failed at newline or so
      text = remaining_text[0, 32]
      text = text.inspect.colorize(:blue).bold.on(:dark_gray)
      "State(#{at}, #{text})"
    end

    def to_s(io)
      io << "State(#{at})"
    end

    def inspect(io)
      to_s(io)
    end
  end

  abstract class Context
    abstract def on_non_terminal(rule : Component, state : State)
    abstract def on_success(rule : Component, state : State, end_state : State)
    abstract def on_failure(rule : Component, state : State)
    abstract def on_error(rule : Component, state : State)
  end

  class EmptyContext < Context
    def on_non_terminal(rule : Component, state : State)
    end

    def on_success(rule : Component, state : State, end_state : State)
    end

    def on_failure(rule : Component, state : State)
    end

    def on_error(rule : Component, state : State)
    end
  end

  # class LoggingContext < Context
  #   getter parse_log : ParseLog

  #   def initialize(@parse_log)
  #   end

  #   def on_non_terminal(rule : Component, state : State)
  #     parse_log.append(ParseLog::Started.new(rule, state.at))
  #   end

  #   def on_success(rule : Component, state : State, end_state : State)
  #     parse_log.append(ParseLog::Success.new(rule, state.at, end_state.at))
  #   end

  #   def on_failure(rule : Component, state : State)
  #     parse_log.append(ParseLog::Failure.new(rule, state.at))
  #   end

  #   def on_error(rule : Component, state : State)
  #     # FIXME store parse errors
  #   end
  # end

  abstract class Component(V)
    def short_name
      # self.class.name.split("::").last
      self.class.name.gsub("Syntaks::", "")
    end

    def as_component : Component(V)
      self.as(Component(V))
    end

    abstract def simple? : Boolean
    abstract def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error

    private def succeed(state : State, end_state : State, value : V, ctx : Context) : Success(V)
      ctx.on_success(self, state, end_state)
      Success(V).new(end_state, value)
    end

    private def fail(state : State, ctx : Context) : Failure
      ctx.on_failure(self, state)
      Failure.new(state)
    end

    private def error(state : State, ctx : Context) : Error
      ctx.on_error(self, state)
      Error.new(state)
    end
  end

  class Seq(A, B, V) < Component(V)
    getter left : Component(A)
    getter right : Component(B)

    # def self.build(left : Component(A), right : Component(B), &action : (A, B) -> V) forall A, B, V
    #   Seq(V).new(left, right, ->(l : A, r : B) { action.call(l, r) })
    # end

    # def self.build(left : Component(A), right : Component(B), action : (A, B) -> V) forall A, B, V
    #   new(left, right, action)
    # end

    # def self.build(left : Component(A), right : Component(B)) forall A, B, V
    #   Seq(V).new(left, right, ->(l : A, r : B) { {l, r} })
    # end

    def self.build(left : Component(A), right : Component(B), &action : (A, B) -> V) forall A, B, V
      Seq(A, B, V).new(left, right, action)
    end

    def self.build(left : Component(A), right : Component(B), action : (A, B) -> V) forall A, B, V
      Seq(A, B, V).new(left, right, action)
    end

    def self.build(left : Component(A), right : Component(B)) forall A, B
      Seq(A, B, {A, B}).new(left, right, ->(a : A, b : B) { {a, b} })
    end

    def initialize(@left, @right, @action : (A, B) -> V) forall A, B
    end

    def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
      case lr = left.call(state, ctx)
      when Success
        case rr = right.call(lr.end_state, ctx)
        when Success
          succeed(state, rr.end_state, @action.call(lr.value, rr.value), ctx)
        when Failure
          fail(rr.end_state, ctx)
        else
          error(rr.end_state, ctx)
        end
      when Failure
        fail(state, ctx)
      else
        error(state, ctx)
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

  class Alt(V) < Component(V)
    getter left, right

    def self.build(*args)
      new(*args)
    end

    def self.build(left : Component(V), right : Component(V))
      Alt(V, V, V).new(left, right, ->(r : V) { r })
    end

    def initialize(@left : Component(V), @right : Component(V), @action : (V) -> V)
    end

    def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
      case lr = left.call(state, ctx)
      when Success
        succeed(state, lr.end_state, lr.value, ctx)
      when Failure
        case rr = right.call(state, ctx)
        when Success then succeed(state, rr.end_state, rr.value, ctx)
        when Failure then fail(rr.end_state, ctx)
        else              error(rr.end_state, ctx)
        end
      else error(state, ctx)
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

    def call(state : State, ctx : Context = EmptyContext.new) : Success(V?) | Failure | Error
      case r = rule.call(state, ctx)
      when Success then succeed(state, r.end_state, r.value, ctx)
      when Failure then succeed(state, state, nil, ctx)
      else              error(state, ctx)
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

    def call(state : State, ctx : Context = EmptyContext.new) : Success(Array(V)) | Failure | Error
      next_state = state
      values = [] of V
      result = rule.call(next_state, ctx)

      loop do
        case result
        when Success
          values << result.value
          next_state = result.end_state
          result = rule.call(next_state, ctx)
        when Failure
          break
        else
          return error(result.end_state, ctx)
        end
      end

      succeed(state, result.end_state, values, ctx)
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

  class NonTerminal(V) < Component(V)
    getter name : String
    # getter referenced_rule : (-> Component(V)) | (-> Terminal(V)) | (-> NonTerminal(V))
    getter referenced_rule : -> Component(V)
    getter action : V -> V

    # def self.build(name : String, referenced_rule : -> Component(V))
    #   NonTerminal(V).new(name, referenced_rule, ->(r : V) { r })
    # end

    # def self.build(name : String, referenced_rule : -> Component(V), &action : V -> V)
    #   NonTerminal(V).new(name, referenced_rule, action)
    # end

    def self.build(name : String, referenced_rule : -> Component(V)) # forall V
      # new(name, referenced_rule) { |v| v }
      new(name, referenced_rule, ->(r : V) { r })
    end

    def initialize(@name, @referenced_rule, @action : V -> V)
    end

    # def initialize(@name, @referenced_rule, @action = ->(r : V) { r })
    # end

    # def initialize(@name, @referenced_rule, &@action)
    # end

    def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
      ctx.on_non_terminal(self, state)
      r = referenced_rule.call.call(state, ctx)
      case r
      when Success(V) then succeed(state, r.end_state, action.call(r.value), ctx)
      else                 fail(state, ctx)
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
      new(matcher, ->(t : Token) { t })
    end

    def self.build(matcher : String | Regex, action : Token -> V)
      new(matcher, action)
    end

    def initialize(@matcher : String | Regex, @action : Token -> V)
    end

    def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
      parsed_text = case m = matcher
                    when String
                      m if state.remaining_text.starts_with?(m)
                    when Regex
                      if r = Regex.new("\\A" + m.source).match(state.remaining_text)
                        r[0]
                      end
                    end

      if parsed_text
        end_state = state.advance(parsed_text.size)
        token = Token.new(state.interval(parsed_text.size))
        value = @action.call(token)
        succeed(state, end_state, value, ctx)
      else
        fail(state, ctx)
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

  # macro rule(name, sequence, &action)
  #   #T_{ {name.upcase.id}} = typeof(build_ebnf({{sequence}}))
  #   #alias T_{{name.id}} = typeof(build_ebnf_type({{sequence}}))
  #   #@{{name.id}} : NonTerminal(T_{{name.id}}) | Nil
  #   macro x_{{name.id}}
  #     typeof(build_ebnf_type({{sequence}}))
  #   end

  #   @{{name.id}} : x_{{name.id}} | Nil

  #   def {{name.id}}
  #     rr = ->{ build_ebnf({{sequence}}) }
  #     @{{name.id}} ||= NonTerminal.build("{{name.id}}", rr) {{action}}
  #   end
  # end

  # macro rule(name, sequence, &action)
  #   def {{name.id}}
  #     rr = ->{ build_ebnf({{sequence}}) }
  #     @{{name.id}} ||= NonTerminal.build("{{name.id}}", rr) {{action}}
  #   end
  # end

  macro instance_var_type(name, seq)
    ENBF.build_ebnf_type({{sequence}})
  end

  macro rule(name, sequence, &action)
    # @{{name.id}} : build_ebnf_type(sequence) | Nil
    # instance_var_type({{name.id}}, {{sequence}})

    def {{name.id}}
      rr = ->{ build_ebnf({{sequence}}) }
      @{{name.id}} ||= NonTerminal.build("{{name.id}}", rr) {{action}}
    end
  end

  macro rule(definition, &action)
    EBNF.rule({{definition.target.stringify}}, {{definition.value}}) {{action}}
  end

  macro rules(&block)
    {% lines = block.body.expressions if block.body.class_name == "Expressions" %}
    {% lines = [block.body] if block.body.class_name == "Assign" %}
    {% for d in lines %}
      {% if d.class_name != "Assign" %}
        {% raise "Error: only assignments are allowed, but got a #{d.class_name}: #{d}" %}
      {% else %}
        EBNF.rule({{d}})
      {% end %}
    {% end %}
  end

  class Dummy
  end

  class Ref
  end

  macro build_ebnf_type(arg)
    {%
      t = arg.class_name
      res = if t == "Call"
              argname = "#{arg.name}"
              if arg.receiver && [">>", "&"].includes?(argname)
                "typeof(Tuple.new(build_nested_ebnf_type(#{arg.receiver}), build_nested_ebnf_type(#{arg.args.first})))"
              elsif argname == "|"
                "build_ebnf_type(#{arg.receiver}) | build_ebnf_type(#{arg.args.first})"
              elsif argname == "~"
                "build_ebnf_type(#{arg.receiver})"
              else
                "typeof(#{arg.name})"
                # "Ref"
              end
            elsif t == "TupleLiteral"
              "build_ebnf_type(#{arg[0]})"
            elsif %w(StringLiteral RegexLiteral).includes?(t)
              "Dummy"
            end
    %}
    {{res.id}}
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
            elsif %w(StringLiteral RegexLiteral).includes?(t)
              "Terminal.build(#{arg})"
            else
              "NonTerminal.build(\"#{arg}\", ->{ #{arg} })"
            end
    %}
    {{res.id}}
  end
end

abstract class Parser
  include EBNF

  abstract def root : Component

  def call(input : String)
    call(Source.new(input))
  end

  def call(source : Source) # : Success | Failure | Error
    root.call(State.new(source, 0))
  end
end

class ExampleParser < Parser
  macro build_ebnf_x(arg)
    {%
      t = arg.class_name
      res = if t == "Call"
              argname = "#{arg.name}"
              if arg.receiver && [">>", "&"].includes?(argname)
                # "Seq.build(build_ebnf_x(#{arg.receiver}), build_ebnf_x(#{arg.args.first}))"
                first = if arg.receiver.class_name == "Call" && [">>", "&"].includes?(arg.receiver.name.stringify)
                          "l[0],l[1]"
                        else
                          "l"
                        end
                second = if arg.args.first.class_name == "Call" && [">>", "&"].includes?(arg.args.first.name.stringify)
                           "r[0],r[1]"
                         else
                           "r"
                         end

                <<-CRYSTAL
                  Seq.build(
                    build_ebnf_x(#{arg.receiver}),
                    build_ebnf_x(#{arg.args.first})
                  ) do |l, r|
                    {#{first.id},#{second.id}}
                  end
                CRYSTAL
              elsif argname == "|"
                "Alt.build(build_ebnf_x(#{arg.receiver}), build_ebnf_x(#{arg.args.first}))"
              elsif argname == "~"
                "Opt.new(build_ebnf_x(#{arg.receiver}))"
              else
                "#{arg}"
              end
            elsif t == "TupleLiteral"
              "Rep.new(build_ebnf_x(#{arg[0]}))"
            elsif %w(StringLiteral RegexLiteral).includes?(t)
              "Terminal.build(#{arg})"
            else
              "#{arg}"
            end
    %}
    {{res.id}}
  end

  macro rulex(name, t, definition)
    @{{name.id}} : NonTerminal({{t}})?

    def {{name.id}}
      @{{name.id}} ||= NonTerminal.build("{{name.id}}", ->{
        (build_ebnf_x({{definition}})).as_component
      })
    end
  end

  rulex(:root, {EBNF::Token, EBNF::Token, EBNF::Token}, "def " >> id >> ";")
  rulex(:id, EBNF::Token, /\w+/)
end

e = ExampleParser.new
res = e.call("def asd;")
p res
