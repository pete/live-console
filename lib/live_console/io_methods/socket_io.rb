class LiveConsole::IOMethods::SocketIO

	DefaultOpts = {
		:host => '127.0.0.1'
	}.freeze
	RequiredOpts = DefaultOpts.keys + [:port]

	def start
		@server ||= TCPServer.new host, port

		begin
			self.raw = @server.accept_nonblock
			return true
		rescue Errno::EAGAIN, Errno::ECONNABORTED, Errno::EPROTO,
			   Errno::EINTR => e
			stop
			retry
		end
	end

	def stop
		IO.select [@server], [], [], 1 if @server
		raw.close rescue nil
	end

	include LiveConsole::IOMethods::IOMethod
end
