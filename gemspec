require 'rubygems'
require 'lib/live_console_config'

SPEC = Gem::Specification.new { |s|
	s.name = 	LiveConsoleConfig::PkgName
	s.version =	LiveConsoleConfig::Version
	s.author = 	LiveConsoleConfig::Authors
	s.email = 	LiveConsoleConfig::Email
	s.homepage =	LiveConsoleConfig::URL
	s.rubyforge_project = LiveConsoleConfig::Project
	s.platform =	Gem::Platform::RUBY
	s.summary =	
	    'A library to support adding a console to your running application.'
	s.files = Dir.glob("{bin,doc,lib}/**/*").delete_if { |file|
		[ /\/rdoc\//i,     # No rdoc
		].find { |rx| rx.match file }
	}
	s.require_path 'lib'
	s.has_rdoc = true
	s.extra_rdoc_files = Dir['doc/*'].select(&File.method(:file?))
	Dir['bin/*'].map(&File.method(:basename)).map(&s.executables.method(:<<))
}

if __FILE__ == $0
	Gem::Builder.new(SPEC).build
end
