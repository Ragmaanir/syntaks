require "./spec_helper"

# module SyntaksTests
#   class ListParserTest < Minitest::Test
#     class Parser < Syntaks::Parser
#       include EBNF

#       # rule(root, {assignment >> /[ \t]*\n/})
#       rule(root, {assignment})
#       rule(assignment, id >> /\s+/ >> "=" >> /\s+/ >> value)
#       rule(id, /\w+/)
#       rule(value, id | /\d+/)
#     end

#     def test_acceptance
#       Parser.new.call("test = 15").as Success
#     end
#   end
# end

# describe Syntaks::Parser do
#   class Parser < Syntaks::Parser
#     # rule(root, {Syntaks::Token, Syntaks::Token}, "def " >> /\w+/)

#     rule(root, Array(Token), {assignment})
#     rule(assignment, {Token, Token, Token, Token, Token}, id >> /\s+/ >> "=" >> /\s+/ >> value)
#     rule(id, Token, /\w+/)
#     rule(value, Token, id | /\d+/)

#     # rules do
#     #   id = /\w+/
#     #   value = id | /\d+/
#     #   assignment = id >> /\s+/ >> "=" >> /\s+/ >> value
#     #   root = {assignment}
#     # end
#   end

#   test "acceptance" do
#     # Parser.new.call("test = 15").as Success
#     p Parser.new.call("def asdrtest")
#   end
# end

describe Syntaks::Parser do
  class Parser < Syntaks::Parser
    rule(root, {Token, Token, Token, Token}, id >> "=" >> value >> ";")
    rule(id, Token, /\w+/)
    rule(value, Token, /\d+/)
  end

  test "acceptance" do
    r = Parser.new.call("a=5;").as Success
    assert r.value.map { |v| v.content } == {"a", "=", "5", ";"}

    r = Parser.new.call("number=1337;").as Success
    assert r.value.map { |v| v.content } == {"number", "=", "1337", ";"}
  end
end

describe ActionParser do
  class Parser < Syntaks::Parser
    rule(root, {String, Int32}, id >> "=" >> value) do |v|
      {v[0], v[2]}
    end

    rule(id, String, /\w+/) { |t| t.content }
    rule(value, Int32, /\d+/) { |t| t.content.to_i }
  end

  test "AST" do
    r = Parser.new.call("var=12345").as(Success)
    assert r.value == {"var", 12345}
  end
end
