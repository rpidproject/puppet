require File.dirname(__FILE__) + '/nagios_plugin.rb'
require "date"

class SSLExpiryChecker < NagiosPlugin
  def check( url, warn, crit )
    result = `curl -vIs https://#{url} 2>&1 |grep expire`
    if result =~ /expire date: (.*)/
      expire_date = $1
    else
      raise "Problem parsing curl output"
    end
    days_to_expiry = Date.parse(expire_date) - Date.today
    message = "Cert expires in #{days_to_expiry} days. | expires=#{days_to_expiry}d"
    if days_to_expiry > crit and days_to_expiry <= warn then
        return warning( message )
    end
    if days_to_expiry <= crit then
        return critical( message )
    end
    return ok( message )
  end
end
