require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'yaml'

class PuppetChecker < NagiosPlugin

    def initialize( yaml_path = "/var/lib/puppet/yaml/node", stream = STDOUT )
        @yaml_path = yaml_path
        super( stream )
    end
    
    def last_run_time( server )
        filename = `grep -l #{server} #{@yaml_path}/*.yaml |head -1`.chomp
        data = YAML.load_file( filename )
        data.ivars["time"]
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
    
    def check( server, max_age )
        t = Time.now - last_run_time( server )
        message = "Puppet last ran #{time_interval( t )} ago."
        if t <= max_age
            return ok( message )
        else
            return critical( message )
        end
    end
end
