# LiveConsole
# Pete Elmore (pete.elmore@gmail.com), 2007-10-18
# debu.gs/live-console
# See doc/LICENSE.

require 'irb'
require 'socket'
require 'live_console_config'

# LiveConsole provides a socket that can be connected to via netcat or telnet
# to use to connect to an IRB session inside a running process.  It creates a
# thread that listens on the specified address/port, and presents connecting
# clients with an IRB shell.  Using this, you can execute code on a running
# instance of a Ruby process to inspect the state or even patch code on the
# fly.  There is currently no readline support.
class LiveConsole
	include Socket::Constants
	autoload :IOMethods, 'live_console/io_methods'

	attr_accessor :io_method, :io, :thread
	private :io_method=, :io=, :thread=
	
	# call-seq:
	#	# Bind a LiveConsole to localhost:3030:
	# 	LiveConsole.new :socket, :port => 3030
	#	# Accept connections from anywhere on port 3030.  Ridiculously insecure:
	# 	LiveConsole.new(:socket, :port => 3030, :host => '0.0.0.0')
	#	# More secure:
	#	LiveConsole.new(:unix_socket, :path => '/tmp/my_liveconsole.sock',
	#	                :mode => 0600)
	#
	# Creates a new LiveConsole.  You must next call LiveConsole#run when you
	# want to spawn the thread to accept connections and run the console.
	def initialize(io_method, opts = {})
		self.io_method = io_method.to_sym
		unless IOMethods::List.include?(self.io_method)
			raise ArgumentError, "Unknown IO method: #{io_method}" 
		end

		init_io opts
	end

	# LiveConsole#run spawns a thread to listen for, accept, and provide an IRB
	# console to new connections.  If a thread is already running, this method
	# simply returns false; otherwise, it returns the new thread.
	def run
		return false if thread
		self.thread = Thread.new { 
			loop {
				Thread.pass
				if io.start
					irb_io = GenericIOMethod.new io.raw_input, io.raw_output
					begin
						IRB.start_with_io(irb_io)
					rescue Errno::EPIPE => e
						io.stop
					end
				end
			}
		}
		thread
	end

	# Ends the running thread, if it exists.  Returns true if a thread was
	# running, false otherwise.
	def stop
		if thread
			thread.exit
			self.thread = nil
			true
		else
			false
		end
	end

	private

	def init_irb
		return if @@irb_inited_already
		IRB.setup nil
		@@irb_inited_already = true
	end

	def init_io opts
		self.io = IOMethods.send(io_method).new opts
	end
end

# We need to make a couple of changes to the IRB module to account for using a
# weird I/O method and re-starting IRB from time to time.  
module IRB
	@inited = false

	# Overridden a la FXIrb to accomodate our needs.
	def IRB.start_with_io(io, &block)
		unless @inited
			setup '/dev/null'
			IRB.parse_opts
			IRB.load_modules
			@inited = true
		end

		irb = Irb.new(nil, io, io)

		@CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
		@CONF[:MAIN_CONTEXT] = irb.context
		@CONF[:PROMPT_MODE] = :INF_RUBY

		catch(:IRB_EXIT) { 
			begin
				irb.eval_input
			rescue StandardError => e
				irb.print([e.to_s, e.backtrace].flatten.join("\n") + "\n")
				retry
			end
		}
		irb.print "\n"
	end

	class Context
		# Fix an IRB bug; it ignores your output method.
		def output *args
			@output_method.print *args
		end
	end

	class Irb
		# Fix an IRB bug; it ignores your output method.
		def printf(*args)
			context.output(sprintf(*args))
		end

		# Fix an IRB bug; it ignores your output method.
		def print(*args)
			context.output *args
		end
	end
end

# The GenericIOMethod is a class that wraps I/O for IRB.
class GenericIOMethod < IRB::StdioInputMethod
	# call-seq:
	# 	GenericIOMethod.new io
	# 	GenericIOMethod.new input, output
	#
	# Creates a GenericIOMethod, using either a single object for both input
	# and output, or one object for input and another for output.
	def initialize(input, output = nil)
		@input, @output = input, output
		@line = []
		@line_no = 0
	end

	attr_reader :input
	def output
		@output || input
	end

	def gets
		output.print @prompt
		output.flush
		@line[@line_no += 1] = input.gets
		# @io.flush	# Not sure this is needed.
		@line[@line_no]
	end

	# Returns the user input history.
	def lines
		@line.dup
	end

	def print(*a)
		output.print *a
	end

	def file_name
		input.inspect
	end

	def eof?
		input.eof?
	end

	def close
		input.close
		output.close if @output
	end
end
