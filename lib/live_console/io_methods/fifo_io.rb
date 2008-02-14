class LiveConsole::IOMethods::FifoIO
	DefaultOpts = {
		:remove? => false,	# If the file exists, should we remove it?
		:user => nil,		# User to give file ownership to
		:mode => 0600,		# The file's mode
	}.freeze
	RequiredOpts = DefaultOpts.keys + [:filename]

	def start
		maybe_remove!
		if check_file
			make_fifo
		else
			raise Errno::EEXIST, "File exists; either remove it or pass " \
				":remove? => true to LiveConsole.new."
		end
	end

	include LiveConsole::IOMethods::IOMethod
	private

	def maybe_remove!
		if !check_file && remove?
			File.unlink(filename)
		end
	end

	# Returns true if we can create the file.
	def check_file
		!File.exist?(filename)
	end
end
