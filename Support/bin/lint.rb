#!/usr/bin/env ruby
require ENV['TM_SUPPORT_PATH'] + '/lib/escape'

# You'll need to set this path manually to run the unit tests
SUPPORT = ENV['TM_BUNDLE_SUPPORT']
JSL  = "#{SUPPORT}/bin/jsl"
CONF = "#{SUPPORT}/conf/jsl.textmate.conf"
OPTS = %Q{-stdin -nofilelisting -nologo -conf "#{CONF}"}

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
      <h1>JavaScript Validation</h1>
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
  chunks = output.split(/\n\n/)

  # The last line is the summary line
  results = chunks.pop

  # Parse the other lines
  parsed = chunks.map do |chunk|
    chunk.strip!
    next if chunk.empty?

    lines = chunk.split(/\n/)
    first = lines.shift
    first.sub!(/^(\d+):\s+(?:(lint warning)|(SyntaxError)|(Error)):\s+(.*)$/) {
      msg = '<span class="warning">Warning:</span> '    if $2
      msg = '<span class="error">Syntax Error:</span> ' if $3
      msg = '<span class="error">Error:</span> '        if $4
      msg << %Q{<a href="txmt://open?url=file://#{e_url(ENV['TM_FILEPATH'])}&line=#{$1}">#{$5}</a>}
      # Finding the correct column is not always possible, and I'd rather not
      # make the user jump to the wrong place.
    }
    li = "<li>#{first}"
    li << "<pre><code>#{htmlize(lines.join("\n"))}</code></pre>" unless lines.empty?
    li << "</li>"
  end
  [results, parsed]
end

def lint(javascript)
  html(*parse(IO::popen(%Q{"#{JSL}" #{OPTS} 2>&1}, 'r+') { |io|
    io << javascript
    io.close_write
    io.read.chomp
  }))
end

def tabs(text)
  text.gsub(/^\t+/) { |match| ' ' * (ENV['TM_TAB_SIZE'].to_i * match.length) }
end

if __FILE__ == $PROGRAM_NAME
  if ENV['TM_SCOPE']
    puts lint(tabs(STDIN.read))
  end
end
