
def whyrun_supported?
  true
end

use_inline_resources

action :create do
  chef_gem 'chef-vault'
  require 'chef-vault'

  if @current_resource.exists
    Chef::Log.info "#{@new_resource} already exists - nothing to do."
  else
    converge_by("Create #{@new_resource}") do
      create_encrypted_volume
    end
  end
end

action :mount do
  chef_gem 'chef-vault'
  require 'chef-vault'

  if @current_resource.mounted
    Chef::Log.info "#{@new_resource} is already mounted - nothing to do."
  else
    converge_by("Mount #{@new_resource}") do
      mount_encrypted_volume
    end
  end
end

action :mount_or_create do
  chef_gem 'chef-vault'
  require 'chef-vault'

  if (@current_resource.exists && @current_resource.mounted)
    Chef::Log.info "#{@new_resource} is already mounted - nothing to do."
  elsif @current_resource.exists
    converge_by("Mount #{@new_resource}") do
      mount_encrypted_volume
    end
  else
    converge_by("Create #{@new_resource}") do
      create_encrypted_volume
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::EncryptedVolume.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.mount_point(@new_resource.mount_point)

  @current_resource.exists = mount_exists?
  @current_resource.mounted = is_mounted?
end

# private ?

def volume
  new_resource.volume
end

def mount_point
  new_resource.mount_point
end

def mount_exists?
  ::Dir.exists?(mount_point)
end

def is_mounted?
  mount_exists? && ::File.exists?(mount_point + "/.mounted")
end

def mount_options
  new_resource.mount_options
end

def fstype
  new_resource.fstype
end

def crypt_volume
  "crypt-#{new_resource.mount_point.gsub('/','-')}"
end

def mapped_path
  "/dev/mapper/#{crypt_volume}"
end

def new_vault_tag
  "#{node.name}-#{crypt_volume}"
end

def new_passphrase
  SecureRandom.urlsafe_base64(128)
end

def passphrase
  vault = new_resource.vault || node['encrypted_volume']['vault']

  if (new_resource.mode == :onetime) and new_resource.passphrase.nil?
    new_resource.passphrase(new_passphrase)
  end

  if new_resource.passphrase
    # if we are a onetime mount or user specifies a pre-shared key
    return new_resource.passphrase

  elsif vault.nil?
    # bail if someone manages to set vault to nil
    Chef::Log.error "#{@new_resource} - vault cannot be nil."
    raise "#{@new_resource} - vault cannot be nil."
    
  elsif vault_tag = new_resource.vault_tag
    # if we are a pre-shared key in a vault
    Chef::Log.info "#{@new_resource} - Fetching passphrase from [#{vault}/#{vault_tag}]"
    passphrase = ChefVault::Item.load(vault,vault_tag)['passphrase'] rescue nil

    Chef::Log.error "#{@new_resource} - passphrase cannot be nil." if passphrase.nil?
    raise "#{@new_resource} - passphrase cannot be nil." if passphrase.nil?
    
    return passphrase
    
  elsif new_resource.vault_tag.nil?
    # if we need to generate a host-specific key

    vault_tag = new_vault_tag
    Chef::Log.info "#{@new_resource} - Fetching passphrase from [#{vault}/#{vault_tag}]"
    passphrase = ChefVault::Item.load(vault,vault_tag)['passphrase'] rescue nil
    if passphrase.nil?
      Chef::Log.info "#{@new_resource} - Generating passphrase for [#{vault}/#{vault_tag}]"
      passphrase = new_passphrase
      item = ChefVault::Item.new(vault,vault_tag)
      item["passphrase"]= passphrase
      item.search "name:#{node.name}"
      item.clients "name:#{node.name}"
      item.save
    end

    return passphrase
  else
    Chef::Log.error "#{@new_resource} - Invalid passphrase mode"
    raise "#{@new_resource} - Invalid passphrase mode"
  end
end

def create_encrypted_volume
  Chef::Log.debug "#{@new_resource} - Creating encrypted volume [#{volume}]."
  Chef::Log.debug "#{@new_resource} - Using passphrase [#{passphrase}]."
  bash "create_encrypted_volume" do
    code <<-EOH
      HISTSIZE=/dev/null
      # create the volume
      echo #{passphrase} | cryptsetup luksFormat #{volume}
      echo #{passphrase} | cryptsetup luksOpen #{volume} #{crypt_volume}

      # setup the volume and mount point
      mkdir #{mount_point}
      mkfs -t #{fstype} #{mapped_path}
      mount -t #{fstype} #{mapped_path} #{mount_point} && touch #{mount_point}/.mounted
      umount #{mount_point}
      sleep 5 # give the disk time to flush

      # close the volume
      cryptsetup luksClose #{crypt_volume}
    EOH

    # Don't run if we've already created the mount point
    not_if { mount_exists? }
  end
  Chef::Log.info "#{@new_resource} - Created encrypted volume [#{volume}]."

  mount_encrypted_volume
end

def mount_encrypted_volume
  Chef::Log.debug "#{@new_resource} - Using passphrase [#{passphrase}]."
  Chef::Log.debug "#{@new_resource} - Opening encrypted volume [#{volume}]."

  bash "open_encrypted_volume" do
    code <<-EOH
      HISTSIZE=/dev/null
      echo #{passphrase} | cryptsetup luksOpen #{volume} #{crypt_volume}
    EOH
    not_if { is_mounted? }
  end

  Chef::Log.debug "#{@new_resource} - Mounting #{@new_resource}"
  mount mount_point do
    device  mapped_path
    fstype  fstype
    options mount_options
  end
  Chef::Log.info "#{@new_resource} - Mounted #{@new_resource}"
end
