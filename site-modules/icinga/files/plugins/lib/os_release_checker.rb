require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'rubygems'

class OSReleaseChecker < NagiosPlugin
    def check(minimum_version)
	ENV['HOME'] = '/' # Work around http://markmail.org/thread/ytevz6piaqolaud6
        current_version = `/opt/puppetlabs/bin/facter lsbdistrelease`.chomp
        message = "Version #{current_version} is installed, at least #{minimum_version} required."
        if Gem::Version.new(current_version.dup) >= Gem::Version.new(minimum_version.dup)
            return ok( message )
        else
            return warning( message )
        end
    end
end
