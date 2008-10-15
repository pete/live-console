#!/usr/bin/env ruby

require 'rubygems'
require 'live_console'

default_path = "/tmp/lc_example_#{Process.uid}.sock"

print <<-EOF
This is a demo program for LiveConsole.  It starts a LiveConsole at the
specified path, and you can connect to it by using netcat or telnet to connect
to the specified port.  
	Usage:
		#{$0} [path_to_socket [value_for_$x]]
The default path is #{default_path}, and $x is set by default to nil.  
Run this program, and then in a different terminal, connect to it via
the supplied udscat program or the BSD version of netcat.
EOF

path = ARGV.first
path = path.nil? ? default_path : path
$x = ARGV[1]

lc = LiveConsole.new :unix_socket, :path => path
lc.run

puts "My PID is #{Process.pid}, " \
	"I'm running on #{path}, and $x = #{$x.inspect}"

oldx = $x
loop { 
	if $x != oldx
		puts "The time is now #{Time.now.strftime('%R:%S')}.",
			"The value of $x changed from #{oldx.inspect} to #{$x.inspect}."
		oldx = $x
	end
	sleep 1
}
