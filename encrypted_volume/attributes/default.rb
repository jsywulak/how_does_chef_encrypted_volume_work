# chef-vault vault name to use by default. can be overridden in lwrp
default['encrypted_volume']['vault'] = 'encrypted_volumes'

# mounts to manage by configuration, eg
# "encrypted_volume":{
#   "mounts":{
#     "/encrypted":{
#       "volume":"/dev/sda2",
#       "fstype":"ext2"
#     }
#   }
# }
default['encrypted_volume']['mounts'] = {}
