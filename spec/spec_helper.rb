require 'minitest/spec'
require 'minitest/autorun'
require 'turn'

Turn.config do |c|
 c.format  = :dotted
 c.natural = true
 c.trace   = 2
end