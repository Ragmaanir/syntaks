require "microtest"
require "../src/syntaks"
require "./example_parsers"

include Syntaks
include Microtest::DSL

Microtest.run!([
  Microtest::DescriptionReporter.new,
  Microtest::ErrorListReporter.new,
  Microtest::SlowTestsReporter.new,
  Microtest::SummaryReporter.new,
] of Microtest::Reporter)
