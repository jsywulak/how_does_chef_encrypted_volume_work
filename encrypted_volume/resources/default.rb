actions        :mount, :create, :mount_or_create
default_action :mount_or_create

attribute      :volume,        :kind_of => String, :required => true
attribute      :mount_point,   :kind_of => String, :name_attribute => true, :required => true
attribute      :fstype,        :kind_of => String, :default => 'ext2'
attribute      :mount_options, :kind_of => String, :default => 'rw'

attribute      :mode,          :kind_of => Symbol, :default => :normal, :equal_to => [:normal, :onetime]

attribute      :vault,         :kind_of => String
attribute      :vault_tag,     :kind_of => String
attribute      :passphrase,    :kind_of => String

attr_accessor  :exists, :mounted

def initialize(*args)
  super
  @action = :mount_or_create
end

