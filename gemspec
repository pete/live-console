require 'rubygems'
require 'lib/live_console_config'

SPEC = Gem::Specification.new { |s|
	s.name = 	LiveConsoleConfig::PkgName
	s.version =	LiveConsoleConfig::Version
	s.author = 	LiveConsoleConfig::Authors
	s.email = 	LiveConsoleConfig::Email
	s.homepage =	LiveConsoleConfig::URL
	s.platform =	Gem::Platform::RUBY
	s.summary =	
	    'A library to support adding a console to your running application.'
	s.files = Dir.glob("{bin,doc,lib}/**/*").delete_if { |file|
		[ /\/rdoc\//i,     # No rdoc
		].find { |rx| rx.match file }
	}
	s.require_path 'lib'
	s.autorequire = 'live_console'
	s.has_rdoc = true
	s.extra_rdoc_files = %w(doc/README doc/LICENSE doc/lc_example.rb)
}

if __FILE__ == $0
	Gem::manage_gems
	Gem::Builder.new(SPEC).build
end
