require File.dirname(__FILE__) + '/nagios_plugin.rb'

class SwappingChecker < NagiosPlugin
  def check()
    vmstat = `vmstat 5 1 |tail -1`.split
    si, so = vmstat[6].to_i, vmstat[7].to_i
    msg = "Swap in (si): #{si} B/s, swap out (so): #{so} B/s |si=#{si}B/s so=#{so}B/s"
    return ok(msg)
  end
end
