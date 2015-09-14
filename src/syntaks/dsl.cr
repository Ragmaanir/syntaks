require "./parser"
require "./parsers/*"

module Syntaks
  module DSL
    include Syntaks::Parsers

    def str(s : String | Regex)
      TokenParser.new(s)
    end

    # macro seq_macro(block, parser, max)
    #   {% for length in 0..max %}
    #     def seq(
    #     {% for i in 1..length %}
    #       arg{{i}} : Parser(A{{i}}){% if i < length %},{% end %}
    #     {% end %})
    #       SequenceParser.new(
    #         # {% for i in 1..length %}
    #         #   arg{{i}}{% if i < length %},{% end %}
    #         # {% end %}
    #         gen_args(arg, length)
    #       )
    #     end
    #   {% end %}
    # end

    # macro gen_args(prefix, count)
    #   [
    #     {% for i in 1..count %}
    #       {{prefix}}{{i}}{% if i < count %},{% end %}
    #     {% end %}
    #   ]
    # end

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

    macro mseq(*args, &block)
      gen_nested_seq({{args}}, 0){% if block %} do |{{block.args.argify}}|
        {{yield}}
      end
      {% end %}
    end

    def seq(one : Parser(L), two : Parser(R), &block : (L,R) -> T)
      SequenceParser.new(one, two, ->(args : {L,R}){ block.call(args[0], args[1]) })
    end

    # def seq(one : Parser(A), two : Parser(B), three : Parser(C), &block : (A,B,C) -> T)
    #   SequenceParser.new(one, two, ->(args : {L,R}){ block.call(args[0], args[1]) })
    # end

    macro token(arg, t)
      TokenParser({{t.id}}).new({{arg}}, ->(s : String){ {{t.id}}.new(s) })
    end
  end
end
