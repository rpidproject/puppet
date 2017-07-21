require File.dirname(__FILE__) + '/nagios_plugin.rb'

class MotherfsckChecker < NagiosPlugin
  def check()
    result = `grep Stats: /var/log/motherfsck`
    if result.match(/Stats: (\d+) skipped, (\d+) critical, (\d+) OK/)
      skipped = $1.to_i
      bad = $2.to_i
      good = $3.to_i
      message = "#{skipped+bad+good} repos, of which #{bad} critical, #{good} OK, #{skipped} skipped | total=#{skipped+bad+good} critical=#{bad} ok=#{good} skipped=#{skipped}"
      if bad == 0
        return ok(message)
      elsif bad < 50
        return warning(message)
      else
        return critical(message)
      end
    else
      return warning("Problem reading motherfsck logfile")
    end
  end
end
