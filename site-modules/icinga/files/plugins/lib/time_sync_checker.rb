require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'timeout'

class TimeSyncChecker < NagiosPlugin
  def initialize( stream = STDOUT )
    super( stream )
    @check_name = 'TimeSync'
  end

  def check(warning_offset, critical_offset)
    begin
      timeout(8) do
        ntpdate_out = `ntpdate -q -p 1 0.ubuntu.pool.ntp.org |tail -1`.chomp
        if ntpdate_out =~ /offset ([0-9\-\.]+)/
          raw_offset = $1.to_f
        else
          return unknown("Couldn't parse ntpdate output for offset: #{ntpdate_out}")
        end

        abs_offset = raw_offset.abs
        msg = "Absolute offset #{abs_offset} sec (warn #{warning_offset}, critical #{critical_offset})"

        if abs_offset < warning_offset
          return ok(msg)
        elsif abs_offset < critical_offset
          return warning(msg)
        else
          return critical(msg)
        end
      end
    rescue TimeoutError
      return ok("Fetching reference time took too long")
    end
  end
end
