require "./parser"
require "./parsers/*"

module Syntaks
  module DSL
    include Syntaks::Parsers

    def str(s : String | Regex)
      TokenParser.new(s)
    end

    macro gen_nested_seq(args, skip, &block)
      {% if (args.length - skip) == 2 %}
        SequenceParser.new(
          {{args[skip].id}},
          {{args[skip+1].id}}
        )
      {% else %}
        SequenceParser.new(
          {{args[skip].id}},
          gen_nested_seq({{args}}, {{skip + 1}})
        ) {% if skip > 0 %} do |args|
          Tuple.new(args[0], *args[1])
        end
        {% elsif skip == 0 && block %} do |syntaks_args|
          {{block.args.argify}} = Tuple.new(syntaks_args[0], *syntaks_args[1])
          {{yield}}
        end
        {% end %}
      {% end %}
    end

    macro sequence(*args, &block)
      gen_nested_seq({{args}}, 0){% if block %} do |{{block.args.argify}}|
        {{yield}}
      end
      {% end %}
    end

    macro token(arg)
      TokenParser(Nil).new({{arg}}, ->(s : String){ nil })
    end

    macro token(arg, t)
      TokenParser({{t.id}}).new({{arg}}, ->(s : String){ {{t.id}}.new(s) })
    end

    macro rule(name, &definition)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.new ->{ {{yield}} }
      end
    end
  end
end
