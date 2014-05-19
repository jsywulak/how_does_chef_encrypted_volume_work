encrypted_volume Cookbook
=========================
Encrypt your disks! Onetime, persist reboots and be restricted to host, or
persist and possibly be mountable on different hosts.

Attributes
----------

#### encrypted_volume::default
 * vault - name of default `chef-vault` vault; where we keep the
   passphrases
 * mounts - hash of any mounts to encrypt. if you don't wish to use
   the LWRP
   
#### LWRP

 * mount_point - name_attribute - where you want to mount your volume
   to
 * volume - volume you want to encrypt and mount
 * fstype - filesystem to use for volume - default: ext2
 * mount_options - any special mount(5) options - default: rw
 * mode - normal, or onetime. Onetime does not save the key anywhere,
   effectively making the mount usable for one boot
 * vault - what `chef-vault` to store/get passphrase in/from
 * vault_tag - what `chef-vault` item to store/get the passphrase
   in/from. By default we generate this so that it belongs to the
   host. This means you can reboot to your heart's content and use the
   mount. Setting it to a pre-created vault item is useful for volumes
   you might need to move between hosts, like EBS mounts.
 * passphrase - don't use except for testing. I'm looking at you Dave.

Usage
-----
#### encrypted_volume::default

If you wish to encrypt volumes based on configuration, without using
the LWRP. Just include `encrypted_volume` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[encrypted_volume]"
  ],
  "default_attributes":{
    "encrypted_volume":{
      "mounts":{
        "/encrypted":{
        "volume":"/dev/sda2",
        "fstype":"ext2"
      }
    }
  }
}
```

#### LWRP

```ruby
encrypted_volume "/encrypted" do
  volume      "/raw_test_volume.img"
  fstype      "ext3"
end
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Jason Rohwedder <jro@risk.io>
