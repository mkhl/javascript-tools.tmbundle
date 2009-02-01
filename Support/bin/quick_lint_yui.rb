#!/usr/bin/env ruby
FILENAME = ENV['TM_FILENAME']
FILEPATH = ENV['TM_FILEPATH']
SUPPORT  = ENV['TM_BUNDLE_SUPPORT']
JAR      = "#{SUPPORT}/lib/yuicompressor.jar"
JAVA     = ENV['TM_JAVA'] || 'java'

output = `"#{JAVA}" -jar "#{JAR}" --charset utf8 --type js --verbose -o /dev/null "#{FILEPATH}" 2>&1`

# the "X error(s), Y warning(s)" line will always be at the end
errs, warns = output.inject([0, 0]) { |memo, line|
  case line
  when /^\[ERROR\]/
    memo[0] += 1
  when /^\[WARNING\]/
    memo[1] += 1
  end
  memo
}

puts "#{errs} error(s), #{warns} warning(s)" unless [0, 0] == [errs, warns]
