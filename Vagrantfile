
Vagrant.configure(2) do |config|

  config.ssh.forward_agent = true
  config.ssh.keep_alive = true
  
  config.vm.box = "chef/debian-7.4"
  config.vm.hostname = "magento2"
  config.vm.network "private_network", ip: "192.168.56.210"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "4"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["setextradata", :id, "--VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  config.vm.provision :shell, :path => "init.sh"
end
