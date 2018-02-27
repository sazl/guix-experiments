# Depends on the vagrant-disksize plugin
# vagrant plugin install vagrant-disksize

Vagrant.configure("2") do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.provision "shell", path: "provision.sh"
  config.disksize.size = '15GB'
  config.vm.provider "virtualbox" do |v|
    v.memory = 4096
    v.cpus = 2
  end
end
