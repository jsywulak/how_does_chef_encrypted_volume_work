name             'encrypted_volume'
maintainer       'Risk I/O'
maintainer_email 'jro@risk.io'
license          'Apache 2.0'
description      'Installs/Configures encrypted_volume'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'chef-vault'

%w{redhat centos scientific fedora debian ubuntu arch freebsd amazon}.each do |os|
  supports os
end

attribute "vault",
  :display_name => "Vault",
  :description => "Default chef-vault Vault to store/fetch passphrases from"

attribute "mounts",
  :display_name => "Mounts",
  :description => "Hash of volumes to encrypt and mount"
