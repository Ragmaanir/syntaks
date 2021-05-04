require "kontrakt"
require "./syntaks/*"

module Syntaks
  VERSION = {{ `shards version #{__DIR__}`.strip.stringify }}
end
