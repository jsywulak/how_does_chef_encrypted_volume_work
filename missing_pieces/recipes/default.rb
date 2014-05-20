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
volumes = AWS::EC2.new(region: 'us-west-2').volumes
volume = volumes.select {|v| v.id == node[:volume]}.first
stack = cfn.stacks.select{|c| c.name == node[stack_name]}
ops_instance_id = stack.resources.select { |r| r.resource_type == "AWS::OpsWorks::Instance"}.stack_resource_detail.physical_resource_id
ops.describe_instances(instance_ids: [stack.ops_instance_id])[:instances].first[:ec2_instance_id]

# attach the volume
ec2_instance_id = opsworks.describe_instances(instance_ids: [opsworks_instance_id])[:instances].first[:ec2_instance_id]
instance = ec2.instances.select{ |i| i.id == ec2_instance_id }.first

volume.attach_to(instance, 'xvdf')





  instance_id = nil
  cfn.describe_stack_resources(stack_name: stack_name).stack_resources.each do |resource|
    if resource.resource_type == "AWS::OpsWorks::Instance"
      instance_id = cfn.describe_stack_resource(stack_name: stack_name, logical_resource_id: resource.logical_resource_id).stack_resource_detail.physical_resource_id
    end
  end
