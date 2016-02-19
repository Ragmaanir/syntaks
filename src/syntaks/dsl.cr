require "./parser"
require "./parsers/*"

module Syntaks
  module DSL
    include Syntaks::Parsers

    def str(s : String | Regex)
      TokenParser.build(s)
    end

    def optional(parser : Parser(T))
      OptionalParser.new(parser)
    end

    macro gen_nested_seq(args, skip, &block)
      {% if (args.size - skip) == 2 %}
        SequenceParser.new(
          {{args[skip].id}},
          {{args[skip+1].id}}
        ) {% if block %} do |syntaks_args|
            {{block.args.argify}} = syntaks_args
            {{yield}}
          end
        {% end %}
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

    macro alternatives(*args, &block)
      gen_nested_alt({{args}}, 0){% if block %} do |{{block.args.argify}}|
        {{yield}}
      end
      {% end %}
    end

    macro gen_nested_alt(args, skip, &block)
      {% if (args.size - skip) == 2 %}
        AlternativeParser.build(
          {{args[skip].id}},
          {{args[skip+1].id}}
        ) {% if block %} do |syntaks_args|
            {{block.args.argify}} = syntaks_args
            {{yield}}
          end
        {% end %}
      {% else %}
        AlternativeParser.build(
          {{args[skip].id}},
          gen_nested_alt({{args}}, {{skip + 1}})
        ) {% if skip > 0 %} do |args|
          Tuple.new(args[0], *args[1])
        end
        {% elsif skip == 0 && block %} do |syntaks_arg|
          {{block.args.argify}} = syntaks_arg
          {{yield}}
        end
        {% end %}
      {% end %}
    end

    macro token(name, arg, cls)
      token({{name}}, {{arg}}) do |t|
        {{cls}}.new(t)
      end
    end

    macro token(name, arg, &block_or_class)
      {% if block_or_class.is_a?(Nop) %}
        def {{name.id}}
          @{{name.id}} ||= ParserReference.build "{{name.id}}", ->{
            TokenParser.build({{arg}})
          }
        end
      {% else %}
        def {{name.id}}
          @{{name.id}} ||= ParserReference.build "{{name.id}}", ->{
            TokenParser.build({{arg}}, ->(s : Syntaks::Token){
              {{block_or_class.args.argify}} = s
              {{yield}}
            })
          }
        end
      {% end %}
    end

    macro ignored_token(name, arg)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.build "{{name.id}}", ->{
          TokenParser(Nil).build({{arg}}, ->(s : Syntaks::Token){ nil })
        }
      end
    end

    macro rule(name, &definition)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.build "{{name.id}}", ->{ {{yield}} }
      end
    end

    macro transform(name, referenced_rule, &trans)
      rule({{name.id}}) do
        TransformParser.build({{referenced_rule}}) {{trans}}
      end
    end

  end
end
