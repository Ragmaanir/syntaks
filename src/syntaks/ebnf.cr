module Syntaks
  module EBNF

    abstract class Component
      def short_name
        self.class.name.split("::").last
      end
    end

    class Seq < Component
      getter items
      def initialize(@items : Array)
      end

      def ==(other : Seq)
        other.items == items
      end

      def inspect(io)
        io << "#{short_name}(#{items})"
      end
    end

    class Alt < Component
      getter items
      def initialize(@items : Array)
      end

      def ==(other : Alt)
        other.items == items
      end

      def inspect(io)
        io << "#{short_name}(#{items})"
      end
    end

    class Opt < Component
      getter rule
      def initialize(@rule)
      end

      def ==(other : Opt)
        other.rule == rule
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end

    class Rep < Component
      def initialize(@rule)
      end
    end

    class NonTerminal < Component
      getter name
      def initialize(@name : String)
      end

      def ==(other : NonTerminal)
        other.name == name
      end

      def inspect(io)
        io << name
      end
    end

    macro rule(name, sequence)
      to_ebnf({{sequence}})
    end

    macro to_ebnf(arg)
      {%
        t = arg.class_name
        res = if t == "Call"
          argname = "#{arg.name}"
          if arg.receiver && [">>", "&"].includes?(argname)
            "Seq.new([to_ebnf(#{arg.receiver}), to_ebnf(#{arg.args.first})])".id
          elsif argname == "|"
            "Alt.new([to_ebnf(#{arg.receiver}), to_ebnf(#{arg.args.first})])".id
          elsif argname == "~"
            "Opt.new(to_ebnf(#{arg.receiver}))".id
          else
            "NonTerminal.new(\"#{arg.name}\")".id
          end
        elsif t == "Var"
          arg.name
        else
          "NonTerminal.new(\"#{arg}\")".id
        end
      %}
      {{res}}
    end

    macro classof(exp)
      {% t = exp.class_name %}
      puts "CLASS: {{t.id}} EXP: {{exp.id}}"
    end
  end
end
