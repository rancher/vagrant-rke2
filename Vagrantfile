ENV['VAGRANT_I_KNOW_WHAT_IM_DOING_PLEASE_BE_QUIET'] = 'true'

Vagrant.configure("2") do |config|
  config.vagrant.plugins = ["vagrant-reload"]
  

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

  config.vm.define "server" do |server|
    server.vm.box = 'generic/ubuntu2004'
    server.vm.hostname = 'server'
    server.vm.network "private_network", ip: "10.10.10.100", netmask: "255.255.255.0"

    server.vm.provision :rke2, run: "once" do |rke2|
      rke2.env = %w[INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TYPE=server]
      rke2.config_mode = '0644' # side-step https://github.com/k3s-io/k3s/issues/4321
      rke2.config = <<~YAML
        write-kubeconfig-mode: 0644
        token: vagrant-rke2
      YAML
    end
  end

  config.vm.define "agent" do |agent|
    agent.vm.box          = "StefanScherer/windows_2019"
    agent.vm.communicator = "winrm"
    agent.vm.hostname = 'agent'
    agent.vm.network "private_network", ip: "10.10.10.101", netmask: "255.255.255.0"
    
    agent.vm.provision :rke2, run: "once" do |rke2|
      rke2.installer_url = "https://raw.githubusercontent.com/dereknola/rke2/add-requires-check/install.ps1"
      rke2.env = %w[Channel=stable]
      rke2.config = <<~YAML
        kube-proxy-arg: "feature-gates=IPv6DualStack=false"
        server: https://10.10.10.101:9345
        token: vagrant-rke2
      YAML
    end
  end

  
end