require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'time'

class PuppetBranchChecker < NagiosPlugin
    def initialize( stream = STDOUT )
        super( stream )
    end

    def branch()
      git_status = `sudo /usr/local/bin/show_puppet_branch`
      git_status.match(/On branch (.+)/)[1]
    end

    def check( expected_branch = "master" )
        current_branch = branch()
        message = "Puppet is on branch #{current_branch}."
        if current_branch == expected_branch
            return ok( message )
        else
            return warning( message )
        end
    end
end
