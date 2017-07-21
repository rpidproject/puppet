require File.dirname(__FILE__) + '/nagios_plugin.rb'

class CdorkedChecker < NagiosPlugin
  def initialize( stream = STDOUT )
    super( stream )
  end

  def check()
    begin
      sm_segments = `/usr/bin/ipcs -m |/usr/bin/wc -l`.chomp.to_i - 4
      if sm_segments > 0
        return critical("Shared memory segments found; check for CDorked")
      else
        return ok("Shared memory is clean")
      end
    rescue
      return warning("Problem getting shared memory info ")
    end
  end
end
