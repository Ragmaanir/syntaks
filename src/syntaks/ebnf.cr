module Syntaks
  module EBNF
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

    class LoggingContext < Context
      getter parse_log : ParseLog

      def initialize(@parse_log)
      end

      def on_non_terminal(rule : Component, state : State)
        parse_log.append(ParseLog::Started.new(rule, state.at))
      end

      def on_success(rule : Component, state : State, end_state : State)
        parse_log.append(ParseLog::Success.new(rule, state.at, end_state.at))
      end

      def on_failure(rule : Component, state : State)
        parse_log.append(ParseLog::Failure.new(rule, state.at))
      end

      def on_error(rule : Component, state : State)
        # FIXME store parse errors
      end
    end

    abstract class Component(V)
      def short_name
        # self.class.name.split("::").last
        self.class.name.gsub("Syntaks::", "")
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

    class Seq(L, R, V) < Component(V)
      getter left, right

      def self.build(left : Component(L), right : Component(R), &action : (L, R) -> V)
        Seq(L, R, V).new(left, right, ->(l : L, r : R) { action.call(l, r) })
      end

      def self.build(left : Component(L), right : Component(R), action : (L, R) -> V)
        new(left, right, action)
      end

      def self.build(left : Component(L), right : Component(R))
        Seq(L, R, {L, R}).new(left, right, ->(l : L, r : R) { {l, r} })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L, R) -> V)
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

    class Alt(L, R, V) < Component(V)
      getter left, right

      def self.build(*args)
        new(*args)
      end

      def self.build(left : Component(L), right : Component(R))
        Alt(L, R, L | R).new(left, right, ->(r : L | R) { r })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L | R) -> V)
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

    class NonTerminal(R, V) < Component(V)
      getter name : String
      getter referenced_rule : -> Component(R)
      getter action : R -> V

      def self.build(name : String, referenced_rule : -> Component(R))
        NonTerminal(R, R).new(name, referenced_rule, ->(r : R) { r })
      end

      def self.build(name : String, referenced_rule : -> Component(R), &action : R -> V)
        NonTerminal(R, V).new(name, referenced_rule, action)
      end

      def initialize(@name, @referenced_rule, @action)
      end

      def call(state : State, ctx : Context = EmptyContext.new) : Success(V) | Failure | Error
        ctx.on_non_terminal(self, state)
        r = referenced_rule.call.call(state, ctx)
        case r
        when Success(R) then succeed(state, r.end_state, action.call(r.value), ctx)
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

    macro rule(name, sequence, &action)
      def {{name.id}}
        rr = ->{ build_ebnf({{sequence}}) }
        tmp = NonTerminal.build("{{name.id}}", rr) {{action}}
        @{{name.id}} = tmp # without the tmp var the compiler complains about the type of the instance var

      end
    end

    macro rule(definition, &action)
      rule({{definition.target}}, {{definition.value}}) {{action}}
    end

    macro rules(&block)
      {% lines = block.body.expressions if block.body.class_name == "Expressions" %}
      {% lines = [block.body] if block.body.class_name == "Assign" %}
      {% for d in lines %}
        {% if d.class_name != "Assign" %}
          Error: only assignments are allowed, but got a {{d.class_name}}: {{d}}
        {% else %}
          rule({{d}})
        {% end %}
      {% end %}
    end

    # macro build_ebnf(arg)
    #   {%
    #     t = arg.class_name
    #     res = if t == "Call"
    #       argname = "#{arg.name}"
    #       if arg.receiver && [">>", "&"].includes?(argname)
    #         "Seq.build(build_ebnf(#{arg.receiver}), build_ebnf(#{arg.args.first}))"
    #       elsif argname == "|"
    #         "Alt.build(build_ebnf(#{arg.receiver}), build_ebnf(#{arg.args.first}))"
    #       elsif argname == "~"
    #         "Opt.new(build_ebnf(#{arg.receiver}))"
    #       else
    #         "NonTerminal.build(\"#{arg.name}\", ->{ #{arg.name} })"
    #       end
    #     elsif t == "TupleLiteral"
    #       "Rep.new(build_ebnf(#{arg[0]}))"
    #     elsif %w{StringLiteral RegexLiteral}.includes?(t)
    #       "Terminal.build(#{arg})"
    #     else
    #       "NonTerminal.build(\"#{arg}\", ->{ #{arg} })"
    #     end
    #   %}
    #   {{res.id}}
    # end

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
                  # "typeof(#{arg.name})"
                  "Ref"
                end
              elsif t == "TupleLiteral"
                "build_ebnf_type(#{arg[0]})"
              elsif %w(StringLiteral RegexLiteral).includes?(t)
                "Dummy"
              end
      %}
      {{res.id}}
    end

    macro build_nested_ebnf_type(arg)
      {%
        t = arg.class_name
        res = if t == "Call"
                argname = "#{arg.name}"
                if arg.receiver && [">>", "&"].includes?(argname)
                  "Tuple.new(build_nested_ebnf_type(#{arg.receiver}), build_nested_ebnf_type(#{arg.args.first}))"
                elsif argname == "|"
                  "build_ebnf_type(#{arg.receiver}) | build_ebnf_type(#{arg.args.first})"
                elsif argname == "~"
                  "build_ebnf_type(#{arg.receiver})"
                else
                  # "typeof(#{arg.name})"
                  "Ref.new"
                end
              elsif t == "TupleLiteral"
                "build_ebnf_type(#{arg[0]})"
              elsif %w(StringLiteral RegexLiteral).includes?(t)
                "Dummy.new"
              end
      %}
      {{res.id}}
    end

    macro unpack_tuple(var, arg)
      {%
        t = arg.class_name
        res = if t == "Call"
                argname = "#{arg.name}"
                if arg.receiver && [">>", "&"].includes?(argname)
                  "[unpack_tuple(#{var}[0], #{arg.receiver}), unpack_tuple(#{var}[1], #{arg.args.first})]"
                else
                  var.id
                end
              elsif t == "TupleLiteral"
                # "#{var}(#{arg[0]})"
                var.id
              elsif %w(StringLiteral RegexLiteral).includes?(t)
                var.id
              end
      %}
      {{res.id}}
    end

    macro unpack_nested_tuples(arg)
      # {% str = "unpack_tuple(argument, #{arg})" %}
      # {{str.id}}
      unpack_tuple(argument, {{arg}})
    end

    macro xyz(arg)
      {%
        code = %{"#{arg.id}"}
        result = expand(code)
        # result = run("./eval_macro.cr", code)


      %}
      puts {{code}}
      puts {{result.id}}
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

    # flatten a tuple literal
    # macro flatten_tuple(t)
    #   {%
    #     queue = [] of ASTNode
    #     res = [] of ASTNode
    #   %}
    #   {% for e in t %}
    #     {% queue << e %}
    #   {% end %}
    #   {% for e,i in queue %}
    #     {% if e.class_name == "TupleLiteral" %}
    #       {% new_q = [] of ASTNode %}
    #       {% for n, j in e %}
    #         {% new_q << n %}
    #       {% end %}
    #       {% for item, i in new_q%}
    #         {% queue << item %}
    #         {% for ignore,j in queue %}
    #           {% queue[queue.size-j] = queue[queue.size-(j+1)]  %}
    #         {% end %}
    #       {% end %}
    #     {% else %}
    #       {% res << e %}
    #     {% end %}
    #   {% end %}
    #   { {{*res}} }
    # end

  end
end
