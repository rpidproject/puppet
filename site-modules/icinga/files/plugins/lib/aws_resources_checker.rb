require File.dirname(__FILE__) + '/nagios_plugin.rb'
require 'aws-sdk-core'

class AWSResourcesChecker < NagiosPlugin
  def check(ec2_expected, rds_expected)
    ec2 = Aws::EC2::Client.new(region:'us-east-1')
    ec2_instances = ec2.describe_instances(filters:[{ name: 'instance-state-name', values: ['running'] }])
    ec2_found = ec2_instances.reservations.length
    rds = Aws::RDS::Client.new(region: 'us-east-1')
    rds_instances = rds.describe_db_instances()
    rds_found = rds_instances.length
    message = "#{ec2_found} EC2 found, #{ec2_expected} expected; #{rds_found} RDS found, #{rds_expected} expected| ec2=#{ec2_found} rds=#{rds_found}"
    ec2_difference = (ec2_expected - ec2_found).abs
    rds_difference = (rds_expected - rds_found).abs
    if ec2_difference > 2 or rds_difference > 2
      return critical(message)
    elsif ec2_difference > 0 or rds_difference > 0
      return warning(message)
    else
      return ok(message)
    end
  end
end
