require "./parser"
require "./parsers/*"

module Syntaks
  module DSL
    include Syntaks::Parsers

    def str(s : String | Regex)
      TokenParser.new(s)
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
        AlternativeParser.new(
          {{args[skip].id}},
          {{args[skip+1].id}}
        ) {% if block %} do |syntaks_args|
            {{block.args.argify}} = syntaks_args
            {{yield}}
          end
        {% end %}
      {% else %}
        AlternativeParser.new(
          {{args[skip].id}},
          gen_nested_alt({{args}}, {{skip + 1}})
        ) {% if skip > 0 %} do |args|
          Tuple.new(args[0], *args[1])
        end
        {% elsif skip == 0 && block %} do |syntaks_args|
          {{block.args.argify}} = syntaks_args[0]
          {{yield}}
        end
        {% end %}
      {% end %}
    end

    macro token(name, arg)
      #TokenParser(Nil).new({{arg}}, ->(s : String){ nil })
      def {{name.id}}
        @{{name.id}} ||= ParserReference.new "{{name.id}}", ->{
          TokenParser(Nil).new({{arg}}, ->(s : Syntaks::Token){ nil })
        }
      end
    end

    # macro token(arg, t)
    #   TokenParser({{t.id}}).new({{arg}}, ->(s : String){ {{t.id}}.new(s) })
    # end

    macro token(name, arg, t)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.new "{{name.id}}", ->{
          TokenParser({{t.id}}).new({{arg}}, ->(s : Syntaks::Token){ {{t.id}}.new(s) })
        }
      end
    end

    macro ignored_token(name, arg)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.new "{{name.id}}", ->{
          TokenParser(Nil).new({{arg}}, ->(s : Syntaks::Token){ nil })
        }
      end
    end

    macro rule(name, &definition)
      def {{name.id}}
        @{{name.id}} ||= ParserReference.new "{{name.id}}", ->{ {{yield}} }
      end
    end
  end
end
