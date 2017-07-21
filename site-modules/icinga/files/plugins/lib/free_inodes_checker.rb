require File.dirname(__FILE__) + '/nagios_plugin.rb'

class FreeInodesChecker < NagiosPlugin
  def check( fs, warn, crit )
    percent_used = `df -i #{fs} |tail -1 |awk '{print $5}'`.to_i
    percent_free = 100 - percent_used
    message = "Free inodes are at #{percent_free}% | free=#{percent_free}%"
    if percent_free <= warn and percent_free > crit then
        return warning( message )
    end
    if percent_free <= crit then
        return critical( message )
    end
    return ok( message )
  end
end

