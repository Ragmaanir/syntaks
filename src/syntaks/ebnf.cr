require "./ebnf/component"
require "./ebnf/*"

module Syntaks
  module EBNF
    macro rule(name, types, sequence, &action)
      # FIXME cannot build exact type, so have to use more general type
      #@{{name.id}} : NonTerminal({{types}})?
      @{{name.id}} : Component({{types}})?

      {% if types.is_a?(TupleLiteral) %}
        {% t = "Tuple(#{types.splat})" %}
      {% else %}
        {% t = types %}
      {% end %}

      def {{name.id}} : Component({{t.id}})
        rr = ->{ (build_ebnf({{sequence}})).as_component }
        @{{name.id}} ||= NonTerminal.build("{{name.id}}", rr) {{action}}
      end
    end

    macro ignored(name, sequence)
      rule({{name.id}}, Nil, {{sequence}}) { nil }
    end

    # macro rule(definition, &action)
    #   rule({{definition.target.stringify}}, {{definition.value}}) {{action}}
    # end

    # macro rules(&block)
    #   {% lines = block.body.expressions if block.body.class_name == "Expressions" %}
    #   {% lines = [block.body] if block.body.class_name == "Assign" %}
    #   {% for d in lines %}
    #     {% if d.class_name != "Assign" %}
    #       {% raise "Error: only assignments are allowed, but got a #{d.class_name}: #{d}" %}
    #     {% else %}
    #       rule({{d}})
    #     {% end %}
    #   {% end %}
    # end

    macro build_ebnf(arg)
      {%
        nil # FIXME undefined macro variable 'res'

        # Get rid of expressions wrapper
        if arg.class_name == "Expressions"
          arg = arg.expressions.first
        end

        t = arg.class_name

        res = if t == "Call"
                argname = "#{arg.name}"
                r = arg.receiver

                if r && [">>", "&"].includes?(argname)
                  backtrack = argname == ">>"

                  # Get rid of expressions wrapper
                  if r.class_name == "Expressions"
                    r = r.expressions.first
                  end

                  first = if r.class_name == "Call" && [">>", "&"].includes?(r.name.stringify)
                            "l"
                          else
                            "{l}"
                          end

                  first_arg = arg.args.first

                  # Get rid of expressions wrapper
                  if first_arg.class_name == "Expressions"
                    first_arg = first_arg.expressions.first
                  end

                  second = if first_arg.class_name == "Call" && [">>", "&"].includes?(first_arg.name.stringify)
                             "r"
                           else
                             "{r}"
                           end

                  <<-CRYSTAL
                    Seq.build(
                      build_ebnf(#{arg.receiver}),
                      build_ebnf(#{arg.args.first}),
                      #{backtrack}
                    ) do |l, r|
                      #{first.id} + #{second.id}
                    end
                  CRYSTAL
                elsif argname == "|"
                  "Alt.build(build_ebnf(#{arg.receiver}), build_ebnf(#{arg.args.first}))"
                elsif argname == "~"
                  "Opt.new(build_ebnf(#{arg.receiver}))"
                elsif argname == "-"
                  "NotPredicate.new(build_ebnf(#{arg.receiver}))"
                else
                  arg.stringify
                end
              elsif t == "TupleLiteral"
                "Rep.new(build_ebnf(#{arg[0]}))"
              elsif %w(StringLiteral RegexLiteral).includes?(t)
                "Terminal.build(#{arg})"
              else
                raise "Unhandled case: #{args}"
                # arg.stringify
              end
      %}

      {{res.id}}
    end
  end
end
