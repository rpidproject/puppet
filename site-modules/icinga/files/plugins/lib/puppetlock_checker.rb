require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'time'

class PuppetlockChecker < NagiosPlugin
  LOCKFILE="/var/tmp/puppet.lock"

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

  def check( warn_age )
    if ! File.exists?(LOCKFILE)
        return ok("No lock found")
    end
    lock_time = File.mtime(LOCKFILE)
    lock_age = Time.now - lock_time
    reason = File.open(LOCKFILE).read().chomp
    message = "Lock is #{time_interval(lock_age)} old (reason: #{reason})"
    if lock_age <= warn_age
      return ok( message )
    else
      return warning( message )
    end
  end
end
