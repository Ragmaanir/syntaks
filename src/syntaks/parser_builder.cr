module Syntaks
  class ParserBuilder
    def self.build(&block)
      new(&block).result
    end

    getter :result

    def initialize(&block)
      with self yield self
    end

    class Root < Node
      def initialize(@args : Arguments)
      end
    end

    class Arguments < Node
      def initialize(@children : Array(Node))
      end
    end

    class Argument < Node
      def initialize(@lit : Literal)
      end
    end

    class Literal < Node
      def initialize(@state, @interval)
      end
    end

    # def root
    #   SequenceParser({Literal}, Root).new({"[", literal, "]"}) do |args|
    #     Root.new(args[0])
    #   end
    # end

    def root
      SequenceParser(Root).new([StringParser.new("["), args, StringParser.new("]")]) do |args|
        Root.new(args[0] as Arguments)
      end
    end

    def args
      ListParser(Arguments).new(arg, StringParser.new(","))
    end

    def arg
      SequenceParser(Argument).new([literal]) do |args|
        Argument.new(args[0] as Literal)
      end
    end

    def literal
      TokenParser(Literal).new(/[1-9][0-9]*/)
    end

    # macro seq(t, *args)
    #   SequenceParser({{args.map{|n| p n}}}, {{t}}).new({{*args}}) do |tuple|
    #     {{t}}.new(tuple)
    #   end
    # end

    # def regex(r : Regex, &block : String -> N)
    #   TokenParser(N).new(r)
    # end

    # def opt(rule)
    # end

    # macro list(t, rule, sep_rule)
    #   ListParser({{t}}).new({{rule}}, {{sep_rule}})
    # end

    # def integer_lit
    #   regex(/[1-9][0-9]*/) do |str|
    #   end
    # end

    # def literal
    #   integer_lit
    # end

    # def id_token
    #   regex(/[_a-z][_a-z0-9]*/i) do |str|
    #   end
    # end

    # class MethDef
    # end

    # def meth_def
    #   seq(MethDef, "def", meth_head, endline, meth_body, "end")
    # end

    # def meth_head
    #   seq(id_token, param_list?)
    # end

    # def meth_body
    #   seq
    # end

    # def param_list?
    #   #empty | param_list
    #   param_list
    # end

    # class Parameter
    # end

    # def param_list
    #   list(Parameter, parameter, ",")
    # end

    # def parameter
    #   id_token #| literal
    # end

    # def root
    #   list(meth_def, "\n")
    # end

  end
end
