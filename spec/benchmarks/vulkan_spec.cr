require "../spec_helper"

describe Vulkan do
  # TODO g++ vulkan.h -E > vulkan.expanded.h

  # class LogCtx < Syntaks::EBNF::Context
  #   def on_non_terminal(rule : Syntaks::EBNF::Component, state : Syntaks::State)
  #     # puts("#{rule}: #{state.display}")
  #   end

  #   def on_success(rule : Syntaks::EBNF::Component, state : Syntaks::State, end_state : Syntaks::State)
  #     # puts("SUCC: #{rule} (#{state.at}): #{end_state.display}")
  #   end

  #   def on_failure(rule : Syntaks::EBNF::Component, state : Syntaks::State)
  #     # puts("FAIL: #{rule} (#{state.at}): #{state.display}")
  #   end

  #   def on_error(rule : Syntaks::EBNF::Component, state : Syntaks::State)
  #     puts("ERR: #{state.at}: #{state.display}")
  #   end
  # end

  class Node
  end

  class TypedefNode < Node
    getter name : String

    def initialize(@name)
      # puts "#{self.class.name}: #{name}"
    end
  end

  class TypedefAliasNode < TypedefNode
  end

  class TypedefEnumNode < TypedefNode
  end

  class TypedefFuncNode < TypedefNode
  end

  class TypedefStructNode < TypedefNode
  end

  class FuncNode < Node
    getter name : String

    def initialize(@name)
    end
  end

  class EmptyNode < Node
  end

  class HeaderParser < Syntaks::Parser
    rule(:root, Array(Node), definitions)

    rule(:definitions, Array(Node), {definition}) do |t|
      t.flatten.reject(EmptyNode)
    end

    rule(:definition, Node | Array(Node), _os >> (empty_line | typedef | func | extern_c | preprocessor | inline_comment | multiline_comment)) do |t|
      t[1]
    end

    rule(:empty_line, Node, "\n") { EmptyNode.new.as(Node) }

    rule(:extern_c, Array(Node), "extern" & _s >> "\"C\"" >> _os >> "{" >> _s >> definitions >> _os >> "}") { |t| t[6] }

    rule(:inline_comment, Node, "//" & /.*/) { |_| EmptyNode.new.as(Node) }
    rule(:multiline_comment, Node, "/*" & {-("*/") >> (/./ | "\n")} & "*/") { |_| EmptyNode.new.as(Node) }

    rule(:preprocessor, EmptyNode, "#" & /[^\n]*\n/) { |_| EmptyNode.new }

    rule(:func, FuncNode, type_spec >> _os >> id >> _os >> param_list >> _os >> ";") { |t| FuncNode.new(t[2]) }

    rule(:typedef, TypedefNode, "typedef" >> _s >> (typedef_enum | typedef_struct | typedef_fun | typedef_alias)) { |t| t[2].as(TypedefNode) }

    rule(:typedef_struct, TypedefStructNode, ("struct" | "union") & _s >> id >> _os >> /\*?/ >> _os >> (struct_def | struct_decl) >> _os >> ";") { |t| TypedefStructNode.new(t[2]) }
    rule(:struct_decl, Nil, /[^;]+/) { |_| nil }
    rule(:struct_def, Nil, "{" & _os >> {struct_line >> _os} >> "}" >> _os >> id) { |_| nil }
    # rule(:struct_line, Nil, /[^;\}]+/ >> ";") { |t| nil }
    rule(:struct_line, Nil, type_spec >> _os >> id >> ~arr_spec >> _os >> ";") { |_| nil }
    rule(:typedef_alias, TypedefAliasNode, type_spec & _os >> id >> _os >> ";") { |t| TypedefAliasNode.new(t[2]) }

    rule(:typedef_enum, TypedefEnumNode, "enum" & _s & id >> _s & enum_body >> ";") { |t| TypedefEnumNode.new(t[2]) }
    rule(:enum_body, Nil, "{" >> enum_lines >> "}" >> _os >> id >> _os) { |_| nil }
    rule(:enum_lines, Nil, {enum_line >> ","} >> enum_line) { |_| nil }
    rule(:enum_line, Nil, _os >> id >> _os >> "=" >> _os >> /[^,\}]+/) { |_| nil }

    rule(:typedef_fun, TypedefFuncNode, type_spec >> _os >> fun_ptr >> _os >> param_list >> _os >> ";") { |t| TypedefFuncNode.new(t[2]) }
    rule(:fun_ptr, String, "(" >> _os >> "*" >> _os >> id >> _os >> ")") { |t| t[4] }
    rule(:param_list, Nil, "(" >> _os >> params >> ")") { |_| nil }
    rule(:params, Nil, ~({param >> "," >> _os} >> param)) { |_| nil }
    rule(:param, Nil, %r{[^,\)]+}) { |_| nil }

    rule(:arr_spec, Nil, "[" >> /\d+/ >> "]") { |_| nil }

    rule(:id, String, /[\w_][\w_0-9]*/) { |t| t.content }
    rule(:type_spec, String, primitive_spec | complicated_spec)

    rule(:primitive_spec, String, primitive_type >> _os >> {primitive_type >> _os}) { "x" }
    rule(:primitive_type, String, /signed|short|long|unsigned|char|int|float/ >> -(/[a-zA-Z_0-9]/)) { |t| t[0].content }

    rule(:complicated_spec, String, ~"const" >> _os >> id >> _os >> ~"*" >> _os >> ~"const" >> _os >> ~"*") { |t| t[2] }

    rule(:_os, Nil, /\s*/) { |_| nil }
    rule(:_s, Nil, /\s+/) { |_| nil }
    rule(:_is, Nil, /[ \t]*/) { |_| nil }
  end

  test "parsing vulkan header file" do
    source = File.read(File.join(__DIR__, "vulkan.expanded.h"))

    parser = HeaderParser.new

    res = parser.call(source)
    assert res.is_a?(Success)
  end
end
