module Syntaks
  module EBNF

    abstract class Component(V)
      def short_name
        self.class.name.split("::").last
      end
    end

    class Seq(L,R,V) < Component(V)
      getter left, right

      def self.build(left : Component(L), right : Component(R), action : (L,R) -> V)
        new(left, right, action)
      end

      def self.build(left : Component(L), right : Component(R))
        Seq(L, R, {L,R}).new(left, right, ->(l : L, r : R){ {l,r} })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L,R) -> V)
      end

      def ==(other : Seq)
        other.left == left && other.right == right
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end

    class Alt(L,R,V) < Component(V)
      getter left, right

      def self.build(*args)
        new(*args)
      end

      def self.build(left : Component(L), right : Component(R))
        Alt(L,R, L | R).new(left, right, ->(r : L | R){ r })
      end

      def initialize(@left : Component(L), @right : Component(R), @action : (L | R) -> V)
      end

      def ==(other : Alt)
        other.left == left && other.right == right
      end

      def inspect(io)
        io << "#{short_name}(#{left}, #{right})"
      end
    end

    class Opt(V) < Component(V?)
      getter rule
      def initialize(@rule : Component(V))
      end

      def ==(other : Opt)
        other.rule == rule
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end

    class Rep(V) < Component(Array(V))
      getter rule
      def initialize(@rule : Component(V))
      end

      def ==(other : Rep)
        other.rule == rule
      end

      def inspect(io)
        io << "#{short_name}(#{rule.inspect})"
      end
    end

    class NonTerminal(V) < Component(V)
      getter name, referenced_rule
      def initialize(@name : String, @referenced_rule : -> Component(V))
      end

      def ==(other : NonTerminal)
        other.name == name
      end

      def inspect(io)
        io << name
      end
    end

    class Terminal < Component(String)
      getter matcher
      def initialize(@matcher : String | Regex)
      end

      def ==(other : Terminal)
        other.matcher == matcher
      end

      def inspect(io)
        io << matcher
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
            "Seq.build(to_ebnf(#{arg.receiver}), to_ebnf(#{arg.args.first}))"
          elsif argname == "|"
            "Alt.build(to_ebnf(#{arg.receiver}), to_ebnf(#{arg.args.first}))"
          elsif argname == "~"
            "Opt.new(to_ebnf(#{arg.receiver}))"
          else
            "NonTerminal.new(\"#{arg.name}\", ->{ #{arg.name} })"
          end
        elsif t == "TupleLiteral"
          "Rep.new(to_ebnf(#{arg[0]}))"
        else
          "NonTerminal.new(\"#{arg}\", ->{ #{arg} })"
        end
      %}
      {{res.id}}
    end

    macro classof(exp)
      {% t = exp.class_name %}
      puts "CLASS: {{t.id}} EXP: {{exp.id}}"
    end
  end
end
