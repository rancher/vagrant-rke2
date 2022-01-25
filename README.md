# Vagrant::RKE2
This plugin was heavily inspired by the [vagrant-k3s](https://github.com/dweomer/vagrant-k3s) plugin. Check that out and give dweomer some stars.

## Installation

Vagrant must be >= v2.2.17 

```shell
vagrant plugin install vagrant-rke2
vagrant up --provider=<your favorite provider>
```

## Usage

See the [Vagrantfile](./test/Vagrantfile) for a working example.

### Linux VMs
```ruby
Vagrant.require_version ">= 2.2.17"
Vagrant.configure("2") do |config|
  config.vm.box = 'generic/ubuntu2004'

  config.vm.provision :rke2, run: "once" do |rke2|
    # installer_url: can be anything that curl can access from the guest
    # default =>`https://get.rke2.io`
    # type => String
    rke2.installer_url = 'https://get.rke2.io'

    # env: environment variables to be set before invoking the installer script
    # type => Array<String> || String
    rke2.env = %w[INSTALL_RKE2_CHANNEL=latest INSTALL_RKE2_TYPE=server]
    # or
    rke2.env = <<~ENV
    INSTALL_RKE2_CHANNEL=latest
    INSTALL_RKE2_TYPE=server
    ENV

    # env_path: where to write the envvars to be sourced prior to invoking the installer script
    # default => `/etc/rancher/rke2/install.env`
    rke2.env_path = '/etc/rancher/rke2/install.env'
    rke2.env_mode = '0600' # default
    rke2.env_owner = 'root:root' #default

    # config: config file content in yaml
    # type => String
    rke2.config = <<~YAML
      disable:
      - local-storage
      - servicelb
    YAML
    # config_mode: config file permissions
    # type => String
    # default => `0600`
    rke2.config_mode = '0644' # side-step https://github.com/k3s-io/k3s/issues/4321
    rke2.config_owner = 'root:root' #default

    # install_kubectl: QOL feature, installs latest version of kubectl
    # type => Boolean
    # default => true
    rke2.install_kubectl = false
  end
end
```

### Windows VMs
Windows setup is much more restricted. See https://docs.rke2.io/install/install_options/windows_agent_config/ for more info
```ruby
Vagrant.require_version ">= 2.2.17"
Vagrant.configure("2") do |config|
  config.vm.box          = "StefanScherer/windows_2019"
  config.vm.communicator = "winrm"

  config.vm.provision :rke2, run: "once" do |rke2|
    # installer_url: can be anything that Invoke-WebRequest can access from the guest
    # default =>`https://raw.githubusercontent.com/rancher/rke2/master/install.ps1`
    # type => String
    rke2.installer_url = 'https://raw.githubusercontent.com/rancher/rke2/master/install.ps1'

    # env: environment variables passed to the install.ps1 script
    # type => Array<String> || String
    rke2.env = %w[Channel=latest Method=Tar]
    # or
    rke2.env = "-Channel latest -Method Tar"

    # config: config file content in yaml
    # type => String
    # NOTE: kube-proxy-arg: "feature-gates=IPv6DualStack=false" is currently a required config for windows
    rke2.config = <<~YAML
      kube-proxy-arg: "feature-gates=IPv6DualStack=false"
      server: https://172.168.1.200:9345
      token: vagrant-rke2
    YAML
  end
end
```

## Development

See https://www.vagrantup.com/docs/plugins/development-basics
- `gem build`
- `VAGRANT_CWD=./test bundle exec vagrant up`
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dereknola/vagrant-rke2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).