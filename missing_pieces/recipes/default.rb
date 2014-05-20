# mkdir /encrypted
directory "/encrypted" do
  owner "root"
  group "root"
  mode 00644
  action :create
end

# hey look, just freeform ruby code. 
# and hardcoded values!!
# that's a sure sign you shouldn't use this code anywhere close to any real life application.
# you're not even reading the comments, are you.

# find the volume
require 'aws-sdk'
ec2 = AWS::EC2.new(region: 'us-west-2')
volumes = ec2.volumes
volume = volumes.select {|v| v.id == node[:volume]}.first
cfn = AWS::CloudFormation.new(region: 'us-west-2')
stack = cfn.stacks.select{|c| c.name == node[:stack_name]}.first
ops_instance_id = stack.resources.select { |r| r.resource_type == "AWS::OpsWorks::Instance"}.first.physical_resource_id
ops = AWS::OpsWorks.new(region: 'us-east-1').client
ops.describe_instances(instance_ids: [ops_instance_id])[:instances].first[:ec2_instance_id]

# attach the volume
ec2_instance_id = ops.describe_instances(instance_ids: [ops_instance_id])[:instances].first[:ec2_instance_id]
instance = ec2.instances.select{ |i| i.id == ec2_instance_id }.first
volume.attach_to(instance, 'xvdf')

# and then go on to encrypt the volume
# but seriously don't use this anywhere
