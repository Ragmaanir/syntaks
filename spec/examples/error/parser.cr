class ErrorParser < Syntaks::Parser
  rule(:root, String, "var " & /[1-9][0-9]*/) { |m| m[1].content }
end
