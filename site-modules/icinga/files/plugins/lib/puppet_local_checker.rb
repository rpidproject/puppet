require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'time'

class PuppetLocalChecker < NagiosPlugin

    LASTRUNFILE="/tmp/puppet.lastrun"

    def initialize( stream = STDOUT )
        super( stream )
    end

    def time_interval( seconds )
      hours = mins = 0
      if seconds >=  60 then
        mins = (seconds / 60).to_i
        seconds = (seconds % 60 ).to_i

        if mins >= 60 then
          hours = (mins / 60).to_i
          mins = (mins % 60).to_i
        end
      end
      "#{hours} hours, #{mins} mins, #{seconds} seconds"
    end

    def check( max_age )
        if ! File.exists?( LASTRUNFILE )
            return critical( "Puppet has not run since last boot" )
        end
        last_run_time = Time.parse(`cat #{LASTRUNFILE}`)
        t = Time.now - last_run_time
        message = "Puppet last ran #{time_interval( t )} ago."
        if t <= max_age
            return ok( message )
        else
            return critical( message )
        end
    end
end
