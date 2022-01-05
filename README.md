# Vagrant::RKE2
This plugin was heavily inspired by the [vagrant-k3s](https://github.com/dweomer/vagrant-k3s) plugin. Check that out and give dweomer some stars.

## Installation

```shell
vagrant plugin install vagrant-rke2
vagrant up --provider=<your favorite provider>
```

## Usage

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = ""
  config.vm.provision :rke2, run: "once" do |rke2|
   
  end
end

```
## Development

See https://www.vagrantup.com/docs/plugins/development-basics

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dereknola/vagrant-rke2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](CODE_OF_CONDUCT.md).