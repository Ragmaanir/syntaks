module ExampleParsers
  include Syntaks::EBNF

  class MethodParser < Syntaks::Parser
    class Def
      getter name : String
      getter statements : Array(Stat)

      def initialize(@name, @statements)
      end
    end

    class Stat
      getter name : String
      getter statements : Array(Stat)

      def initialize(@name, @statements = [] of Stat)
      end
    end

    rule(:root, Array(Def), {_os >> definition}) { |arr| arr.map(&.[1]) }
    rule(:definition, Def, "def" >> _s >> id >> _nl >> statements >> _os >> "end") do |t|
      Def.new(t[2], t[4])
    end

    rule(:statements, Array(Stat), {_os >> -/end\s/ >> statement & _nl}) { |arr| arr.map(&.[2]) }
    rule(:statement, Stat, if_stat | assign_stat | call_stat)

    rule(:if_stat, Stat, "if" >> _s & id >> _nl >> statements >> _os >> "end") { |t| Stat.new(t[2], t[4]) }
    rule(:assign_stat, Stat, id >> _os >> "=" & _os >> id) { |t| Stat.new(t[0]) }
    rule(:call_stat, Stat, id >> "(" & _os >> ")") { |t| Stat.new(t[0]) }

    rule(:id, String, /[_a-z][_a-z0-9]*/) { |r| r.content }

    ignored(:_os, /\s*/)
    ignored(:_s, /\s+/)
    ignored(:_nl, /[ \t]*\n/)
  end
end
