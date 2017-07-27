require "./ebnf/component"
require "./ebnf/*"

module Syntaks
  module EBNF
    macro rule(name, types, sequence, &action)
      # FIXME cannot build exact type, so have to use more general type
      #@{{name.id}} : NonTerminal({{types}})?
      @{{name.id}} : Component({{types}})?

      def {{name.id}}
        rr = ->{ (build_ebnf({{sequence}})).as_component }
        @{{name.id}} ||= NonTerminal.build("{{name.id}}", rr) {{action}}
      end
    end

    macro rule(definition, &action)
      rule({{definition.target.stringify}}, {{definition.value}}) {{action}}
    end

    macro rules(&block)
      {% lines = block.body.expressions if block.body.class_name == "Expressions" %}
      {% lines = [block.body] if block.body.class_name == "Assign" %}
      {% for d in lines %}
        {% if d.class_name != "Assign" %}
          {% raise "Error: only assignments are allowed, but got a #{d.class_name}: #{d}" %}
        {% else %}
          rule({{d}})
        {% end %}
      {% end %}
    end

    macro build_ebnf(arg)
      {%
        t = arg.class_name
        res = if t == "Call"
                argname = "#{arg.name}"
                if arg.receiver && [">>", "&"].includes?(argname)
                  backtrack = argname == ">>"
                  first = if arg.receiver.class_name == "Call" && [">>", "&"].includes?(arg.receiver.name.stringify)
                            "l"
                          else
                            "{l}"
                          end
                  second = if arg.args.first.class_name == "Call" && [">>", "&"].includes?(arg.args.first.name.stringify)
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
                arg.stringify
              end
      %}
      {{res.id}}
    end
  end
end
