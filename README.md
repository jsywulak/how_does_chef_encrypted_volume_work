how_does_chef_encrypted_volume_work
===================================

playing around with chef-encrypted-volume cookbooks.

     aws cloudformation create-stack --output json --stack-name "Test-EncryptionStack-`date +%Y%m%d%H%M%S`" --template-body "`cat test.template`" --region us-west-2  --disable-rollback --capabilities="CAPABILITY_IAM" 

will only work in us-west-2. It sets up an EBS volume, and then passes that info about into Chef. Chef then attaches the volume to the instance, sets it up for encryption, and then mounts the encrypted volume so you can happily write data to it.


