require "microtest"
require "../src/syntaks"
require "./example_parsers"

include Syntaks
include Microtest::DSL

Microtest.run!
