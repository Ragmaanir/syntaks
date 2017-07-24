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

describe Syntaks::Parser do
  class Parser < Syntaks::Parser
    # rule(root, {assignment >> /[ \t]*\n/})
    # rule(root, {assignment})
    # rule(assignment, id >> /\s+/ >> "=" >> /\s+/ >> value)
    # rule(id, /\w+/)
    # rule(value, id | /\d+/)

    EBNF.rules do
      id = /\w+/
      value = id | /\d+/
      assignment = id >> /\s+/ >> "=" >> /\s+/ >> value
      root = {assignment}
    end
  end

  def test_acceptance
    Parser.new.call("test = 15").as Success
  end
end
