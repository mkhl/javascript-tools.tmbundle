#!/usr/bin/env ruby
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'

SUPPORT = ENV['TM_BUNDLE_SUPPORT']
JAR = "#{SUPPORT}/lib/yuicompressor.jar"
JAVA = ENV['TM_JAVA'] || 'java'
OPTS = "--charset utf8 --type js --verbose -o /dev/null"

def html(heading, contents)
  html = <<-HTML
  <html>
    <head>
      <title>JavaScript Validation Results</title>
      <style type="text/css">
        span.warning {color: #c90;text-transform: uppercase;font-weight: bold;}
        span.error   {color: #900;text-transform: uppercase;font-weight: bold;}
      </style>
    </head>
    <body>
      <h1>JavaScript Validation (YUI)</h1>
      <h2>#{heading}</h2>
      <ul>
        #{contents}
      </ul>
    </body>
  </html>  
  HTML
  html
end

def parse(output)
  warnings = 0
  errors = 0
  parsed = output.split(/\n\n/).map do |chunk|
    chunk.strip!
    next if chunk.length == 0

    lines = chunk.split(/\n/)
    first = lines.shift
    case first
    when /^\[ERROR\]\s+(\d+):(\d+):(.+)/
      errors += 1
      first = %Q{<span class="error">Error:</span> <a href="txmt://open?url=file://#{e_url(ENV['TM_FILEPATH'])}&line=#{$1}&column=#{$2}">#{$3}</a>}
    when /^\[WARNING\]\s+(.+)/
      warnings += 1
      first = %Q{<span class="warning">Warning:</span> #{$1}}
    end

    out = "<li>#{first}"
    out << "<pre><code>#{lines.join("\n")}</code></pre>" unless lines.empty?
    out << "</li>"
    out
  end.join("\n")
  ["#{errors} error(s), #{warnings} warning(s)", parsed]
end

def lint(javascript)
  html(*parse(`"#{JAVA}" -jar "#{JAR}" #{OPTS} "#{ENV['TM_FILEPATH']}" 2>&1`.chomp))
end

if __FILE__ == $0
  puts lint(STDIN.read)
end
