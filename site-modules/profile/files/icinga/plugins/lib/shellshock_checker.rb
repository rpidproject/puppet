require File.dirname(__FILE__) + '/nagios_plugin.rb'

class ShellshockChecker < NagiosPlugin
  def check()
    cmd = File.dirname(__FILE__) + '/shellshock_test.sh'
    output = `#{cmd} 2>/dev/null`
    matches = output.split("\n").grep(/^(\S+) .*VULNERABLE/){$1}
    if matches.length > 0
      return critical("bash is VULNERABLE to Shellshock (#{matches.join(',')}), upgrade immediately")
    else
      return ok("bash is Shellshock-proofed")
    end
  end
end
