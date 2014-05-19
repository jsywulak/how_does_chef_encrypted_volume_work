#
# Cookbook Name:: encrypted_volume
# Recipe:: default
#
# Copyright 2014, Risk I/O
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "cryptsetup"

node['encrypted_volume']['mounts'].each_pair do |mount,options|
  encrypted_volume mount do
    volume        options['volume']
    fstype        options['fstype']        if options['fstype']
    mount_options options['mount_options'] if options['mount_options']
    vault         options['vault']         if options['vault']
    vault_tag     options['vault_tag']     if options['vault_tag']
    passphrase    options['passphrase']    if options['passphrase']
  end
end
