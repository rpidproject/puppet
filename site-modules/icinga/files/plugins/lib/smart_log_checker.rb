require File.dirname(__FILE__) + '/../lib/nagios_plugin.rb'
require 'time'

class SmartLogChecker < NagiosPlugin
  def initialize(filename, queries, ignores = [], max_age = nil, age_at = nil, warn_only = nil, warn_matches = 0, crit_matches = 0, stream = STDOUT)
    @filename = filename
    @queries = queries
    @ignores = ignores
    @max_age = max_age
    @warn_only = warn_only
    @warn_matches = warn_matches
    @crit_matches = crit_matches
    if age_at.nil?
      @age_at = Time.now
    else
      @age_at = Time.parse(age_at)
    end
    super(stream)
  end

  def matches
    if @queries.nil?
      return []
    end
    search_pattern = [@queries].join('|')
    ignore_pattern = [@ignores].join('|')
    command = "/bin/grep -i -E '#{search_pattern}' #{@filename} "
    if @ignores
      command += "|/bin/grep -i -v -E '#{ignore_pattern}'"
    end
    results = `#{command}`.split(/\r?\n/)
    return results
  end
  
  def too_old?
    return false if @max_age.nil? or @max_age.zero?
    modified = File.mtime(@filename)
    age = (@age_at - modified) / 60
    return age > @max_age
  end

  def check
    results = matches
    alert = nil
    if results.length > 0
      alert = "(#{results.length}) #{results.last}"
    elsif too_old?
      alert = "#{@filename} is too old (max age #{@max_age} minutes at #{@age_at.to_s})"
      if @warn_only
        return warning(alert)
      else
        return critical(alert)
      end
    end
    if alert.nil?
      return ok("Log check ok - 0 pattern matches found")
    else
      if @warn_only.nil? and results.length > @crit_matches
        return critical(alert)
      elsif results.length > @warn_matches
        return warning(alert)
      else
        return ok(alert)
      end
    end
  end
end
