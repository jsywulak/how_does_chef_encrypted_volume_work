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

# make the volume
require 'aws-sdk'
volumes = AWS::EC2.new(region: 'us-west-2').volumes
volume = volumes.select {|v| v.id == node[:volume]}.first

# attach the volume
opsworks_instance_id = node[:instance_id]
ec2_instance_id = opsworks.describe_instances(instance_ids: [opsworks_instance_id])[:instances].first[:ec2_instance_id]
instance = ec2.instances.select{ |i| i.id == ec2_instance_id }.first

volume.attach_to(instance, 'xvdf')



