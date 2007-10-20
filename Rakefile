require 'rake'
require 'rake/testtask'

require 'fileutils'

require 'lib/live_console_config'

$distname = "#{LiveConsoleConfig::PkgName}-#{LiveConsoleConfig::Version}"
$tgz = "#{$distname}.tar.gz"
$tarbz2 = "#{$distname}.tar.bz2"
$gem = "#{$distname}.gem"
$exclude = %W(
	--exclude=#{$distname}/#{$distname}
	--exclude=distrib
	--exclude=tags
	--exclude='.*.swp'
	--exclude='.*.tar.*z*'
	--exclude=.svn
	--exclude=.config
	--exclude=_darcs
).join(' ')

task :default => :packages

task(:packages) {
	FileUtils.mkdir_p 'distrib'
	system "ruby gemspec"
	system "mv #{$distname}.gem distrib"

	Dir.chdir 'distrib'
	system "ln -sf .. #{$distname}"
	system "tar czhf #{$tgz} #{$exclude} #{$distname}"
	system "tar cjhf #{$tarbz2} #{$exclude} #{$distname}"
	Dir.chdir '..'

	File.unlink "distrib/#{$distname}"
}

task(:install => :packages) {
	system "gem install distrib/#{$gem}"
}

task(:clean) {
	system "rm -rf distrib"
}

task(:doc) {
	system "rdoc -N -S -U -o doc/rdoc -m doc/README -x _darcs -x setup.rb lib/* doc/*"
}
