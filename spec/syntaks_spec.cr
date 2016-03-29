 require "./spec_helper"

module SyntaksTests
  class ListParserTest < Minitest::Test
    class Parser < Syntaks::Parser
      include EBNF

      #rule(root, {assignment >> /[ \t]*\n/})
      rule(root, {assignment})
      rule(assignment, id >> /\s+/ >> "=" >> /\s+/ >> value)
      rule(id, /\w+/)
      rule(value, id | /\d+/)
    end

    def test_acceptance
      #assert Parser.new.call("test = 15").success?
      x = Parser.new.call("test = 15") as Success
      assert x.success?
    end

  end
end
