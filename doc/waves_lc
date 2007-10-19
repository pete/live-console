#!/usr/bin/env ruby

require 'rubygems'
require 'live_console'

print <<-EOF
This is a demo program for LiveConsole.  It starts a LiveConsole on the
specified port, and you can connect to it by using netcat or telnet to connect
to the specified port.  
	Usage:
		#{$0} [port_number [value_for_$x]]
The default port is 3333, and $x is set by default to nil.  Run this program,
and then in a different terminal, connect to it via netcat or telnet.  You can
check that the value of $x is exactly what you set it to, and that you're
working inside this process, but there's not much to do inside the example
script.  :)
EOF

port = ARGV.first.to_i
port = port.zero? ? 3333 : port
$x = ARGV[1]

lc = LiveConsole.new port
lc.run

loop { puts "I'm still alive. (#{Time.now})"; sleep 10 }
