source = <<-SRC
  def main
    if true
      x = 1
      ⬤
    end
  end
SRC

ctx = LoggingContext.new(ParseLog.new(Source.new(source)))
res = ExampleParsers::MethodParser.new.call(source, ctx).as(Error)

log = ctx.parse_log.to_s

# The syntax error entry marked with ⚡ should be on the line that contains ⬤
assert(/⚡[^\n]+(29-33)[^\n]+⬤/ === log)
