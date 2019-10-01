class ErrorParser < Syntaks::Parser
  rule(:root, String, "var" >> space & /[a-z]+/) { |m| m[2].content }
  ignored(:space, /\s+/)
end
