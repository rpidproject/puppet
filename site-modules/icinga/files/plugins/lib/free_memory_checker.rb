require File.dirname(__FILE__) + '/nagios_plugin.rb'

class FreeMemoryChecker < NagiosPlugin
  def check( warn, crit )
    meminfo = File.open('/proc/meminfo').read()
    total = meminfo.scan(/MemTotal: +(\d+)/)[0][0].to_i
    free = meminfo.scan(/MemFree: +(\d+)/)[0][0].to_i
    buffers = meminfo.scan(/Buffers: +(\d+)/)[0][0].to_i
    cached = meminfo.scan(/Cached: +(\d+)/)[0][0].to_i
    available = free + buffers + cached
 
    percent_free = (available * 1.0 / total * 100).to_i
    message = "Free memory is at #{percent_free}% | free=#{percent_free}%"
    if percent_free <= warn and percent_free > crit then
        return warning( message )
    end
    if percent_free <= crit then
        return critical( message )
    end
    return ok( message )
  end
end

