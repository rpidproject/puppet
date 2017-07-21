require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'rubygems'
require 'time'

class PuppetVersionChecker < NagiosPlugin
    def initialize( stream = STDOUT )
        super( stream )
    end

    def check(minimum_version)
        current_version = `sudo /usr/bin/puppet --version`.chomp
        message = "Puppet version is #{current_version} (minimum #{minimum_version})."
        if Gem::Version.new(current_version.dup) >= Gem::Version.new(minimum_version.dup)
            return ok( message )
        else
            return warning( message )
        end
    end
end
