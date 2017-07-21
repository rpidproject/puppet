require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'open-uri'
require 'rubygems'
require 'json'
class JSONChecker < NagiosPlugin
  def check(uri)
    json = open(uri, "Accept" => "application/json").read
    begin
      result = JSON.parse(json)
      return ok("passed")
    rescue Exception => e
      return critical("failed to parse")
    end
  end
end
