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
volume = volumes.create availability_zone: 'us-west-2a', size: 10

# attach the volume
id = node[:instance_id]
instance = ec2.instances.select{ |i| i.id == id }.first

volume.attach_to(instance, 'xvdf')