require 'rake'
require 'rake/testtask'

require 'fileutils'

require 'lib/live_console_config'

def dinstall(dir, verbose = false)
	['bin', 'lib'].each { |f|
		install f, dir, verbose
	}
end

$distname = "#{LiveConsoleConfig::PkgName}-#{LiveConsoleConfig::Version}"
$tgz = "#{$distname}.tar.gz"
$tarbz2 = "#{$distname}.tar.bz2"
$gem = "#{$distname}.gem"
$exclude = %W(
	--exclude=#{$distname}/#{$distname}
	--exclude=distrib
	--exclude=tags
	--exclude=rdoc
	--exclude=.*.swp
	--exclude=.svn
	--exclude=.config
	--exclude=Rakefile
).join(' ')

task :default => :packages

task(:packages) {
	FileUtils.mkdir_p 'distrib'
	system "ruby gemspec"
	system "mv #{$distname}.gem distrib"

	system "ln -sf . #{$distname}"

	system "tar czhf distrib/#{$tgz} #{$distname} #{$exclude}"
	system "tar cjhf distrib/#{$tarbz2} #{$distname} #{$exclude}"

	File.unlink "#{$distname}"
}

task(:install) {
	system "ruby setup.rb install"
}
