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

lc = LiveConsole.new :socket, :port => port
lc.start

puts "My PID is #{Process.pid}, " \
	"I'm running on port #{port}, and $x = #{$x.inspect}"

oldx = $x
loop { 
	if $x != oldx
		puts "The time is now #{Time.now.strftime('%R:%S')}.",
			"The value of $x changed from #{oldx.inspect} to #{$x.inspect}."
		oldx = $x
	end
	sleep 1
}
