ENV['VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET'] = 'true'

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-reload"]
  config.vm.box          = "StefanScherer/windows_2019"
  config.vm.communicator = "winrm"

  config.vm.provider "virtualbox" do |v|
    v.cpus = 2         
    v.memory = 2048
    # v.gui = true
    # v.customize ["modifyvm", :id, "--vram", 128]
    # v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    # v.customize ["modifyvm", :id, "--accelerate3d", "on"]
    # v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
    v.linked_clone = true
  end

  # config.vm.provision "shell", path: "./scripts/install-containers-feature.ps1", privileged: false
  # config.vm.provision "reload"
  config.vm.provision :rke2, run: "once" do |rke2|
    rke2.installer_url = "https://raw.githubusercontent.com/dereknola/rke2/add-requires-check/install.ps1"
    rke2.config = <<~YAML
      server: https://172.168.1.200:9345
      node-name: "THISISATEST"
      token: vagrant-rke2
    YAML
  end
end