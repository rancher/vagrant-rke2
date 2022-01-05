begin
  require 'vagrant'
rescue LoadError
  raise 'The Vagrant RKE2 plugin must be run within Vagrant.'
end

require_relative 'vagrant-rke2/plugin'
require_relative 'vagrant-rke2/version'